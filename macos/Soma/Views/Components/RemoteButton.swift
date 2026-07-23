import SwiftUI

/// A glass remote tile: an SF Symbol with an optional uppercase caption.
/// Reused across every control cluster so styling stays consistent.
struct RemoteButton: View {
    let symbol: String
    var label: String? = nil
    var prominent: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                if let label {
                    Text(label)
                        .font(Theme.heading(10, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 46)
        }
        .buttonStyle(RemoteTileStyle(prominent: prominent))
    }
}
