import SwiftUI

/// Directional pad with OK. Each button also binds to the matching arrow /
/// return key, so the whole pad is drivable from the keyboard when the window
/// is focused.
struct DPadView: View {
    let onKey: (RemoteKey) -> Void

    private let tile: CGFloat = 52
    private let arrowHeight: CGFloat = 36

    var body: some View {
        VStack(spacing: 6) {
            arrow(.up, "chevron.up", .upArrow, "Up")
            HStack(spacing: 6) {
                arrow(.left, "chevron.left", .leftArrow, "Left")
                Button {
                    onKey(.ok)
                } label: {
                    Text("OK")
                        .font(Theme.ui(14, weight: .semibold))
                        .frame(width: tile, height: tile)
                }
                .buttonStyle(RemoteTileStyle(prominent: true))
                .keyboardShortcut(.return, modifiers: [])
                arrow(.right, "chevron.right", .rightArrow, "Right")
            }
            arrow(.down, "chevron.down", .downArrow, "Down")
        }
    }

    private func arrow(_ key: RemoteKey, _ symbol: String, _ shortcut: KeyEquivalent, _ label: LocalizedStringKey) -> some View {
        Button {
            onKey(key)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: tile, height: arrowHeight)
        }
        .buttonStyle(RemoteTileStyle())
        .keyboardShortcut(shortcut, modifiers: [])
        .accessibilityLabel(label)
    }
}
