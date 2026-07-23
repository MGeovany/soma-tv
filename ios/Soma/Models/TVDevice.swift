import Foundation

/// A single Samsung TV the user has configured. Persisted to disk so the app
/// remembers the IP, the authorization token and the MAC (for Wake-on-LAN).
struct TVDevice: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var ipAddress: String
    /// MAC address for Wake-on-LAN, e.g. "AA:BB:CC:DD:EE:FF". Optional.
    var macAddress: String
    /// Use the secure `wss://` transport on port 8002 (newer Tizen TVs).
    /// Only secure connections return a reusable authorization token.
    var useSecure: Bool
    /// Authorization token returned by the TV. Kept so we don't re-prompt.
    var token: String?

    init(id: UUID = UUID(),
         name: String = "",
         ipAddress: String = "",
         macAddress: String = "",
         useSecure: Bool = true,
         token: String? = nil) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        self.useSecure = useSecure
        self.token = token
    }

    var displayName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? ipAddress : name
    }
}
