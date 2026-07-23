import Foundation

/// Minimal controller that talks to a Samsung Smart TV over the local
/// WebSocket "remote control" protocol (Tizen, api/v2).
///
/// The first connection makes the TV show an on-screen authorization prompt.
/// Once the user accepts it on the TV, key commands start working.
///
/// Two transports are supported:
/// - Insecure: `ws://IP:8001/...`  (older / simpler)
/// - Secure:   `wss://IP:8002/...` (newer TVs; self-signed cert + token)
@MainActor
final class SamsungTVController: NSObject, ObservableObject {

    @Published var status: String = "Disconnected"
    @Published var isConnected: Bool = false

    private var task: URLSessionWebSocketTask?
    private lazy var session: URLSession = {
        // Delegate is needed to accept the TV's self-signed certificate on wss.
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    // Name shown on the TV's authorization prompt. Must be Base64 encoded.
    private let appName = "Soma"

    // Token returned by the TV after authorization. Kept in memory only
    // (no disk persistence) and reused on reconnect so the TV doesn't
    // re-prompt every time within this app session.
    private var token: String?

    // MARK: - Connection

    func connect(ip: String, secure: Bool) {
        let ip = ip.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ip.isEmpty else {
            status = "Enter the TV IP address first"
            return
        }

        // The app name must be sent Base64 encoded in the `name` query param.
        let encodedName = Data(appName.utf8).base64EncodedString()

        let scheme = secure ? "wss" : "ws"
        let port = secure ? 8002 : 8001

        var urlString = "\(scheme)://\(ip):\(port)/api/v2/channels/samsung.remote.control?name=\(encodedName)"
        if let token, !token.isEmpty {
            urlString += "&token=\(token)"
        }

        guard let url = URL(string: urlString) else {
            status = "Invalid URL: \(urlString)"
            return
        }

        disconnect()

        status = "Connecting to \(ip):\(port)…\nAccept the prompt on the TV if it appears."
        print("[Soma] Connecting to: \(urlString)")

        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()

        // Start listening for messages before/while sending anything.
        receive()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
    }

    // MARK: - Sending keys

    func sendKey(_ key: String) {
        guard let task else {
            status = "Not connected"
            return
        }

        // Standard Samsung remote command envelope.
        let payload: [String: Any] = [
            "method": "ms.remote.control",
            "params": [
                "Cmd": "Click",
                "DataOfCmd": key,
                "Option": "false",
                "TypeOfRemote": "SendRemoteKey"
            ]
        ]

        guard
            let data = try? JSONSerialization.data(withJSONObject: payload),
            let json = String(data: data, encoding: .utf8)
        else {
            status = "Failed to encode command"
            return
        }

        print("[Soma] Sending key: \(key)")
        task.send(.string(json)) { [weak self] error in
            guard let error else { return }
            Task { @MainActor in
                self?.status = "Send error: \(error.localizedDescription)"
                print("[Soma] Send error: \(error)")
            }
        }
    }

    // MARK: - Receiving

    private func receive() {
        task?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("[Soma] Received: \(text)")
                    Task { @MainActor in self.handleMessage(text) }
                case .data(let data):
                    print("[Soma] Received data: \(data.count) bytes")
                @unknown default:
                    break
                }
                // Keep listening.
                self.receive()

            case .failure(let error):
                print("[Soma] Receive error: \(error)")
                Task { @MainActor in
                    self.isConnected = false
                    self.status = "Connection error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        // The TV sends an "ms.channel.connect" event once the connection is
        // authorized and ready to receive commands. On secure connections it
        // also includes a token we reuse to avoid re-prompting.
        if text.contains("ms.channel.connect") {
            isConnected = true
            status = "Connected — ready to send commands"
            extractToken(from: text)
        } else if text.contains("ms.channel.unauthorized") {
            isConnected = false
            status = "Unauthorized — accept the prompt on the TV and reconnect"
        } else {
            status = "TV says: \(text)"
        }
    }

    private func extractToken(from text: String) {
        guard
            let data = text.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let payload = root["data"] as? [String: Any],
            let token = payload["token"] as? String
        else { return }

        self.token = token
        print("[Soma] Stored token (in memory): \(token)")
    }
}

// MARK: - Self-signed certificate handling (wss)

extension SamsungTVController: URLSessionDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Samsung TVs use a self-signed certificate on port 8002. For a local
        // test tool we accept the server's certificate as-is.
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
