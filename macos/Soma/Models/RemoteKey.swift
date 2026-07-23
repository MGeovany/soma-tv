import Foundation

/// Samsung remote key codes — the `DataOfCmd` value of a `SendRemoteKey`
/// command. Only the keys the UI uses are listed; add more as needed.
enum RemoteKey: String {
    // Navigation
    case up    = "KEY_UP"
    case down  = "KEY_DOWN"
    case left  = "KEY_LEFT"
    case right = "KEY_RIGHT"
    case ok    = "KEY_ENTER"

    // System
    case home   = "KEY_HOME"
    case back   = "KEY_RETURN"
    case menu   = "KEY_MENU"
    case exit   = "KEY_EXIT"
    case source = "KEY_SOURCE"

    // Media
    case playPause   = "KEY_PLAY_BACK"   // toggles on most Tizen TVs
    case stop        = "KEY_STOP"
    case rewind      = "KEY_REWIND"
    case fastForward = "KEY_FF"

    // Volume
    case volumeUp   = "KEY_VOLUP"
    case volumeDown = "KEY_VOLDOWN"
    case mute       = "KEY_MUTE"

    // Channels
    case channelUp   = "KEY_CHUP"
    case channelDown = "KEY_CHDOWN"
    case channelList = "KEY_CH_LIST"

    // Power
    case power = "KEY_POWER"

    // Sources
    case tv    = "KEY_TV"
    case hdmi1 = "KEY_HDMI1"
    case hdmi2 = "KEY_HDMI2"
    case hdmi3 = "KEY_HDMI3"
    case hdmi4 = "KEY_HDMI4"

    /// A numeric key (KEY_0 … KEY_9) for direct channel entry.
    static func digit(_ character: Character) -> RemoteKey? {
        guard character.isNumber else { return nil }
        return RemoteKey(rawValue: "KEY_\(character)")
    }
}
