import SwiftUI

/// Touch directional pad with OK at the center.
struct DPadView: View {
    let onKey: (RemoteKey) -> Void

    private let tile: CGFloat = 74
    private let arrowHeight: CGFloat = 58

    var body: some View {
        VStack(spacing: 8) {
            arrow(.up, "chevron.up", "Up")
            HStack(spacing: 8) {
                arrow(.left, "chevron.left", "Left")
                Button {
                    onKey(.ok)
                } label: {
                    Text("OK")
                        .font(Theme.ui(17, weight: .bold))
                        .frame(width: tile, height: tile)
                }
                .buttonStyle(RemoteTileStyle(prominent: true))
                arrow(.right, "chevron.right", "Right")
            }
            arrow(.down, "chevron.down", "Down")
        }
    }

    private func arrow(_ key: RemoteKey, _ symbol: String, _ label: String) -> some View {
        Button {
            onKey(key)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: tile, height: arrowHeight)
        }
        .buttonStyle(RemoteTileStyle())
        .accessibilityLabel(label)
    }
}
