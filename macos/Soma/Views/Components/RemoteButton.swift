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
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                if let label {
                    Text(label)
                        .font(Theme.caption(9, weight: .medium))
                        .textCase(.uppercase)
                        .tracking(0.3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40)
        }
        .buttonStyle(RemoteTileStyle(prominent: prominent))
    }
}
