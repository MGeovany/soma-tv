import Foundation
import Combine

/// Persists user preferences: the global keyboard shortcuts and whether they
/// are enabled. Single responsibility: storage of settings.
@MainActor
final class SettingsStore: ObservableObject {
    @Published var globalHotKeysEnabled: Bool {
        didSet { defaults.set(globalHotKeysEnabled, forKey: enabledKey) }
    }
    @Published var hotKeys: [HotKeyAction: KeyCombo] {
        didSet { saveHotKeys() }
    }

    private let defaults: UserDefaults
    private let enabledKey = "soma.hotkeys.enabled"
    private let hotKeysKey = "soma.hotkeys"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.globalHotKeysEnabled = defaults.object(forKey: enabledKey) as? Bool ?? false

        // Decode with String keys (HotKeyAction isn't a plist-friendly key).
        if let data = defaults.data(forKey: hotKeysKey),
           let decoded = try? JSONDecoder().decode([String: KeyCombo].self, from: data) {
            var map: [HotKeyAction: KeyCombo] = [:]
            for (raw, combo) in decoded {
                if let action = HotKeyAction(rawValue: raw) { map[action] = combo }
            }
            self.hotKeys = map
        } else {
            self.hotKeys = [:]
        }
    }

    private func saveHotKeys() {
        var encodable: [String: KeyCombo] = [:]
        for (action, combo) in hotKeys { encodable[action.rawValue] = combo }
        if let data = try? JSONEncoder().encode(encodable) {
            defaults.set(data, forKey: hotKeysKey)
        }
    }
}
