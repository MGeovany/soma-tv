import SwiftUI

/// A glass remote tile: an SF Symbol with an optional caption. Reused across
/// every control cluster so styling stays consistent. Sized for touch.
struct RemoteButton: View {
    let symbol: String
    var label: String? = nil
    var prominent: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .medium))
                if let label {
                    Text(label)
                        .font(Theme.ui(11, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58)
        }
        .buttonStyle(RemoteTileStyle(prominent: prominent))
    }
}
