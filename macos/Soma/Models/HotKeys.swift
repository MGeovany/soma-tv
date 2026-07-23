import Carbon.HIToolbox
import AppKit

/// A recordable keyboard shortcut: a virtual key code plus Carbon modifier
/// flags. Codable so it can be persisted, and self-describing for the UI.
struct KeyCombo: Codable, Equatable, Hashable {
    /// Virtual key code (kVK_*).
    var keyCode: UInt32
    /// Carbon modifier mask (cmdKey | optionKey | controlKey | shiftKey).
    var modifiers: UInt32

    /// Builds a combo from an AppKit key event, translating modifier flags.
    init(event: NSEvent) {
        keyCode = UInt32(event.keyCode)
        var mods: UInt32 = 0
        let flags = event.modifierFlags
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        if flags.contains(.option)  { mods |= UInt32(optionKey) }
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        if flags.contains(.shift)   { mods |= UInt32(shiftKey) }
        modifiers = mods
    }

    init(keyCode: UInt32, modifiers: UInt32) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// Human-readable form, e.g. "⌃⌥⇧V".
    var displayString: String {
        var result = ""
        if modifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if modifiers & UInt32(optionKey)  != 0 { result += "⌥" }
        if modifiers & UInt32(shiftKey)   != 0 { result += "⇧" }
        if modifiers & UInt32(cmdKey)     != 0 { result += "⌘" }
        result += KeyCombo.keyName(for: keyCode)
        return result
    }

    /// A subset of virtual key codes mapped to display names. Anything not
    /// listed falls back to a numeric label rather than failing.
    private static func keyName(for code: UInt32) -> String {
        let names: [Int: String] = [
            kVK_ANSI_A: "A", kVK_ANSI_B: "B", kVK_ANSI_C: "C", kVK_ANSI_D: "D",
            kVK_ANSI_E: "E", kVK_ANSI_F: "F", kVK_ANSI_G: "G", kVK_ANSI_H: "H",
            kVK_ANSI_I: "I", kVK_ANSI_J: "J", kVK_ANSI_K: "K", kVK_ANSI_L: "L",
            kVK_ANSI_M: "M", kVK_ANSI_N: "N", kVK_ANSI_O: "O", kVK_ANSI_P: "P",
            kVK_ANSI_Q: "Q", kVK_ANSI_R: "R", kVK_ANSI_S: "S", kVK_ANSI_T: "T",
            kVK_ANSI_U: "U", kVK_ANSI_V: "V", kVK_ANSI_W: "W", kVK_ANSI_X: "X",
            kVK_ANSI_Y: "Y", kVK_ANSI_Z: "Z",
            kVK_ANSI_0: "0", kVK_ANSI_1: "1", kVK_ANSI_2: "2", kVK_ANSI_3: "3",
            kVK_ANSI_4: "4", kVK_ANSI_5: "5", kVK_ANSI_6: "6", kVK_ANSI_7: "7",
            kVK_ANSI_8: "8", kVK_ANSI_9: "9",
            kVK_Space: "␣", kVK_Return: "↩", kVK_Escape: "⎋", kVK_Tab: "⇥",
            kVK_UpArrow: "↑", kVK_DownArrow: "↓",
            kVK_LeftArrow: "←", kVK_RightArrow: "→",
            kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4",
            kVK_F5: "F5", kVK_F6: "F6", kVK_F7: "F7", kVK_F8: "F8",
        ]
        return names[Int(code)] ?? "#\(code)"
    }
}

/// The actions that can be bound to a global keyboard shortcut. Each maps to a
/// single remote key so the hot-key manager stays trivial.
enum HotKeyAction: String, CaseIterable, Identifiable, Codable {
    case volumeUp
    case volumeDown
    case mute
    case playPause
    case channelUp
    case channelDown
    case power

    var id: String { rawValue }

    var title: String {
        switch self {
        case .volumeUp:    return "Subir volumen"
        case .volumeDown:  return "Bajar volumen"
        case .mute:        return "Silenciar"
        case .playPause:   return "Reproducir / Pausar"
        case .channelUp:   return "Canal siguiente"
        case .channelDown: return "Canal anterior"
        case .power:       return "Encender / Apagar"
        }
    }

    var remoteKey: RemoteKey {
        switch self {
        case .volumeUp:    return .volumeUp
        case .volumeDown:  return .volumeDown
        case .mute:        return .mute
        case .playPause:   return .playPause
        case .channelUp:   return .channelUp
        case .channelDown: return .channelDown
        case .power:       return .power
        }
    }
}
