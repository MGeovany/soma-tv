import Foundation

/// Talks to a Samsung Smart TV over the local WebSocket remote-control
/// protocol (Tizen, `api/v2`) and launches apps over the REST API.
///
/// The first connection makes the TV show an on-screen authorization prompt.
/// Once the user accepts it, key commands work and — on `wss://` — the TV
/// returns a token we hand back so the caller can persist it and avoid
/// re-prompting.
///
/// This type owns only the transport and command encoding. It reports state
/// through closures instead of driving the UI, so the view model stays the
/// single source of truth (and the client stays easy to reason about / test).
@MainActor
final class SamsungTVClient: NSObject {

    /// Connection / authorization state changes.
    var onStateChange: ((ConnectionState) -> Void)?
    /// A freshly issued authorization token (secure connections only).
    var onToken: ((String) -> Void)?
    /// Non-fatal, transient notices (e.g. "app not available", "reconnecting").
    var onMessage: ((String) -> Void)?

    private var task: URLSessionWebSocketTask?
    private lazy var session: URLSession = {
        // A delegate is required to accept the TV's self-signed cert on wss.
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    // Name shown on the TV's authorization prompt. Sent Base64-encoded.
    private let appName = "Soma"
    private var device: TVDevice?

    // Automatic reconnection with capped exponential backoff.
    private var shouldReconnect = false
    private var reconnectAttempts = 0
    private var reconnectTask: Task<Void, Never>?
    private let maxReconnectDelay: TimeInterval = 30

    private var state: ConnectionState = .disconnected {
        didSet { onStateChange?(state) }
    }

    // MARK: - Connection lifecycle

    func connect(to device: TVDevice) {
        let ip = device.ipAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ip.isEmpty else {
            state = .error("Enter the TV IP address")
            return
        }
        self.device = device
        shouldReconnect = true
        reconnectAttempts = 0
        openSocket()
    }

    func disconnect() {
        shouldReconnect = false
        reconnectTask?.cancel()
        reconnectTask = nil
        reconnectAttempts = 0
        cancelTask()
        state = .disconnected
    }

    private func openSocket() {
        guard let device else { return }
        let ip = device.ipAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        // The app name must be Base64 encoded in the `name` query parameter.
        let encodedName = Data(appName.utf8).base64EncodedString()
        let scheme = device.useSecure ? "wss" : "ws"
        let port   = device.useSecure ? 8002 : 8001

        var urlString = "\(scheme)://\(ip):\(port)/api/v2/channels/samsung.remote.control?name=\(encodedName)"
        if let token = device.token, !token.isEmpty {
            urlString += "&token=\(token)"
        }
        guard let url = URL(string: urlString) else {
            state = .error("Invalid URL")
            return
        }

        cancelTask()
        state = (device.token?.isEmpty ?? true) ? .awaitingAuthorization : .connecting

        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()
        receive()
    }

    private func cancelTask() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    // MARK: - Commands

    func send(_ key: RemoteKey) {
        guard let task, state.isConnected else {
            onMessage?("Not connected")
            return
        }
        let payload: [String: Any] = [
            "method": "ms.remote.control",
            "params": [
                "Cmd": "Click",
                "DataOfCmd": key.rawValue,
                "Option": "false",
                "TypeOfRemote": "SendRemoteKey",
            ],
        ]
        sendJSON(payload, on: task)
    }

    /// Sends a string to the field currently focused on the TV.
    func sendText(_ text: String) {
        guard let task, state.isConnected else {
            onMessage?("Not connected")
            return
        }
        let encoded = Data(text.utf8).base64EncodedString()
        let payload: [String: Any] = [
            "method": "ms.remote.control",
            "params": [
                "Cmd": encoded,
                "DataOfCmd": "base64",
                "TypeOfRemote": "SendInputString",
            ],
        ]
        sendJSON(payload, on: task)
    }

    private func sendJSON(_ payload: [String: Any], on task: URLSessionWebSocketTask) {
        guard
            let data = try? JSONSerialization.data(withJSONObject: payload),
            let json = String(data: data, encoding: .utf8)
        else {
            onMessage?("Couldn't encode the command")
            return
        }
        task.send(.string(json)) { [weak self] error in
            guard let error else { return }
            Task { @MainActor in self?.onMessage?("Send error: \(error.localizedDescription)") }
        }
    }

    // MARK: - App launch (REST)

    /// Launches a Smart TV app by id. Reports a clear message if the TV
    /// rejects it or the app isn't installed — never fails silently.
    func launchApp(_ app: TVApp) {
        guard let device else {
            onMessage?("Not connected")
            return
        }
        let ip = device.ipAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "http://\(ip):8001/api/v2/applications/\(app.appID)") else {
            onMessage?("Invalid app URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5

        session.dataTask(with: request) { [weak self] _, response, error in
            Task { @MainActor in
                if let error {
                    self?.onMessage?("Couldn't open \(app.name): \(error.localizedDescription)")
                } else if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                    self?.onMessage?("\(app.name) isn't available on this TV")
                } else {
                    self?.onMessage?("Opening \(app.name)…")
                }
            }
        }.resume()
    }

    // MARK: - Receiving

    private func receive() {
        task?.receive { [weak self] result in
            // The completion runs off the main actor; hop back before touching
            // any state and before scheduling the next receive.
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let message):
                    if case let .string(text) = message { self.handleMessage(text) }
                    self.receive() // keep listening
                case .failure(let error):
                    self.handleFailure(error)
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        // The TV emits `ms.channel.connect` once authorized and ready; on
        // secure connections that payload also carries a reusable token.
        if text.contains("ms.channel.connect") {
            reconnectAttempts = 0
            state = .connected
            extractToken(from: text)
        } else if text.contains("ms.channel.unauthorized") {
            state = .unauthorized
        }
    }

    private func handleFailure(_ error: Error) {
        task = nil
        guard shouldReconnect else {
            state = .disconnected
            return
        }
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        reconnectAttempts += 1
        let delay = min(maxReconnectDelay, pow(2.0, Double(min(reconnectAttempts, 5))))
        state = .connecting
        onMessage?("Connection lost. Reconnecting… (attempt \(reconnectAttempts))")

        reconnectTask?.cancel()
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let self, !Task.isCancelled, self.shouldReconnect else { return }
            self.openSocket()
        }
    }

    private func extractToken(from text: String) {
        guard
            let data = text.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let payload = root["data"] as? [String: Any],
            let token = payload["token"] as? String
        else { return }
        onToken?(token)
    }
}

// MARK: - Self-signed certificate handling (wss)

extension SamsungTVClient: URLSessionDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Samsung TVs use a self-signed certificate on port 8002. For a local
        // remote we accept the server's certificate as-is.
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
