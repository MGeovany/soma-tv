import SwiftUI

/// High-level connection / authorization state with a UI-friendly presentation.
///
/// The view layer never inspects raw socket state — it only reads this enum,
/// so connection, authorization and error conditions are always shown clearly
/// instead of failing silently.
enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case awaitingAuthorization
    case connected
    case unauthorized
    case error(String)

    var title: String {
        switch self {
        case .disconnected:          return "Desconectado"
        case .connecting:            return "Conectando…"
        case .awaitingAuthorization: return "Esperando autorización en el televisor…"
        case .connected:             return "Conectado"
        case .unauthorized:          return "No autorizado — acepta el aviso en la tele"
        case .error(let message):    return "Error: \(message)"
        }
    }

    var symbolName: String {
        switch self {
        case .disconnected:                        return "tv.slash"
        case .connecting, .awaitingAuthorization:  return "dot.radiowaves.left.and.right"
        case .connected:                           return "tv"
        case .unauthorized:                        return "lock.trianglebadge.exclamationmark"
        case .error:                               return "exclamationmark.triangle"
        }
    }

    var tint: Color {
        switch self {
        case .connected:                           return .green
        case .connecting, .awaitingAuthorization:  return .orange
        case .unauthorized, .error:                return .red
        case .disconnected:                        return .secondary
        }
    }

    var isConnected: Bool { self == .connected }

    /// True while a connection attempt is in progress (show a spinner).
    var isBusy: Bool {
        switch self {
        case .connecting, .awaitingAuthorization: return true
        default:                                  return false
        }
    }
}
