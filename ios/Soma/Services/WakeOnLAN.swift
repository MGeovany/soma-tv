import Foundation

/// Sends a Wake-on-LAN "magic packet" so a powered-off TV on the LAN turns on.
///
/// A magic packet is 6 bytes of 0xFF followed by the target MAC repeated 16
/// times, broadcast over UDP. Uses only POSIX sockets (no dependencies).
enum WakeOnLAN {

    @discardableResult
    static func send(mac: String,
                     broadcast: String = "255.255.255.255",
                     port: UInt16 = 9) -> Bool {
        guard let macBytes = parse(mac) else { return false }

        var packet = [UInt8](repeating: 0xFF, count: 6)
        for _ in 0..<16 { packet.append(contentsOf: macBytes) }

        let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard fd >= 0 else { return false }
        defer { close(fd) }

        var enabled: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &enabled,
                   socklen_t(MemoryLayout<Int32>.size))

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = inet_addr(broadcast)

        let sent = packet.withUnsafeBytes { buffer -> Int in
            withUnsafePointer(to: &addr) { addrPtr in
                addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                    sendto(fd, buffer.baseAddress, buffer.count, 0,
                           sa, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
        }
        return sent > 0
    }

    /// Parses "AA:BB:CC:DD:EE:FF" or "AA-BB-..." into 6 bytes.
    private static func parse(_ mac: String) -> [UInt8]? {
        let sanitized = mac.filter { !$0.isWhitespace }
        let parts = sanitized.split(whereSeparator: { $0 == ":" || $0 == "-" })
        guard parts.count == 6 else { return nil }
        var bytes = [UInt8]()
        for part in parts {
            guard let value = UInt8(part, radix: 16) else { return nil }
            bytes.append(value)
        }
        return bytes
    }
}
