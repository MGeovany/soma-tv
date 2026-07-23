import Foundation
import Combine

/// Persists the list of configured TVs and the current selection to
/// `UserDefaults` as JSON. Single responsibility: storage of devices.
@MainActor
final class DeviceStore: ObservableObject {
    @Published private(set) var devices: [TVDevice] = []
    @Published private(set) var selectedID: UUID?

    private let defaults: UserDefaults
    private let devicesKey = "soma.devices"
    private let selectionKey = "soma.selectedDevice"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    /// The active device, falling back to the first one if the stored
    /// selection is missing.
    var selected: TVDevice? {
        if let selectedID, let match = devices.first(where: { $0.id == selectedID }) {
            return match
        }
        return devices.first
    }

    func add(_ device: TVDevice) {
        devices.append(device)
        if selectedID == nil { selectedID = device.id }
        save()
    }

    func update(_ device: TVDevice) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        devices[index] = device
        save()
    }

    func remove(_ device: TVDevice) {
        devices.removeAll { $0.id == device.id }
        if selectedID == device.id { selectedID = devices.first?.id }
        save()
    }

    func select(_ device: TVDevice) {
        selectedID = device.id
        save()
    }

    /// Persist a freshly issued auth token onto a device.
    func updateToken(_ token: String, for id: UUID) {
        guard let index = devices.firstIndex(where: { $0.id == id }) else { return }
        guard devices[index].token != token else { return }
        devices[index].token = token
        save()
    }

    // MARK: - Persistence

    private func load() {
        if let data = defaults.data(forKey: devicesKey),
           let saved = try? JSONDecoder().decode([TVDevice].self, from: data) {
            devices = saved
        }
        if let idString = defaults.string(forKey: selectionKey) {
            selectedID = UUID(uuidString: idString)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(devices) {
            defaults.set(data, forKey: devicesKey)
        }
        defaults.set(selectedID?.uuidString, forKey: selectionKey)
    }
}
