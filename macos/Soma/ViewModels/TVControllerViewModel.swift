import Foundation
import Combine

/// Coordinates the client, stores, Wake-on-LAN, sleep timer and global
/// shortcuts, exposing a small surface for the SwiftUI views. All UI state
/// flows through here so views never touch the transport directly.
@MainActor
final class TVControllerViewModel: ObservableObject {

    @Published private(set) var state: ConnectionState = .disconnected
    /// A short, transient message for the UI (auto-clears).
    @Published private(set) var notice: String = ""

    let deviceStore: DeviceStore
    let settings: SettingsStore
    let sleepTimer = SleepTimer()

    private let client = SamsungTVClient()
    private let hotKeys = GlobalHotKeyManager()
    private var noticeClearTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init(deviceStore: DeviceStore? = nil, settings: SettingsStore? = nil) {
        self.deviceStore = deviceStore ?? DeviceStore()
        self.settings = settings ?? SettingsStore()
        forwardChanges()
        wireClient()
        wireHotKeys()
    }

    /// The stores are nested ObservableObjects; SwiftUI only observes this view
    /// model, so re-publish their changes here — otherwise the device list and
    /// selection never refresh in the UI.
    private func forwardChanges() {
        deviceStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        settings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var isConnected: Bool { state.isConnected }

    // MARK: - Wiring

    private func wireClient() {
        client.onStateChange = { [weak self] state in self?.state = state }
        client.onMessage = { [weak self] message in self?.flash(message) }
        client.onToken = { [weak self] token in
            guard let self, let id = self.deviceStore.selected?.id else { return }
            self.deviceStore.updateToken(token, for: id)
        }
    }

    private func wireHotKeys() {
        hotKeys.onAction = { [weak self] action in
            Task { @MainActor in self?.send(action.remoteKey) }
        }
        refreshHotKeys()
    }

    /// Applies the current shortcut settings to the global hot-key manager.
    func refreshHotKeys() {
        hotKeys.update(settings.globalHotKeysEnabled ? settings.hotKeys : [:])
    }

    // MARK: - Connection

    func connectSelected() {
        guard let device = deviceStore.selected else {
            flash("Add a TV first")
            return
        }
        client.connect(to: device)
    }

    func connect(to device: TVDevice) {
        deviceStore.select(device)
        client.connect(to: device)
    }

    func disconnect() { client.disconnect() }

    func toggleConnection() {
        isConnected ? disconnect() : connectSelected()
    }

    // MARK: - Commands

    func send(_ key: RemoteKey) { client.send(key) }

    func sendText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        client.sendText(trimmed)
        flash("Text sent")
    }

    func launch(_ app: TVApp) { client.launchApp(app) }

    /// Types a channel number digit by digit and confirms with OK.
    func enterChannel(_ number: String) {
        let digits = number.filter { $0.isNumber }
        guard !digits.isEmpty else { return }
        for character in digits {
            if let key = RemoteKey.digit(character) { client.send(key) }
        }
        client.send(.ok)
    }

    // MARK: - Power

    /// Turns the TV on via Wake-on-LAN (needs the MAC address).
    func powerOn() {
        guard let device = deviceStore.selected else {
            flash("Add a TV first")
            return
        }
        guard !device.macAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
            flash("Add the TV's MAC address to power it on over the network")
            return
        }
        if WakeOnLAN.send(mac: device.macAddress) {
            flash("Power-on signal sent")
        } else {
            flash("Invalid MAC address")
        }
    }

    func powerOff() { client.send(.power) }

    // MARK: - Sleep timer

    func startSleepTimer(minutes: Int) {
        sleepTimer.start(minutes: minutes) { [weak self] in self?.powerOff() }
        flash("TV will turn off in \(minutes) min")
    }

    func cancelSleepTimer() { sleepTimer.cancel() }

    // MARK: - Notices

    private func flash(_ message: String) {
        notice = message
        noticeClearTask?.cancel()
        noticeClearTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            self?.notice = ""
        }
    }
}
