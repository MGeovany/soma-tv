import SwiftUI

/// A compact remote button: an SF Symbol with an optional caption. Reused
/// across every control cluster so styling stays consistent.
struct RemoteButton: View {
    let symbol: String
    var label: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.title3)
                if let label {
                    Text(label)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
    }
}
