import SwiftUI

/// Directional pad with OK. Each button also binds to the matching arrow /
/// return key, so the whole pad is drivable from the keyboard when the window
/// is focused.
struct DPadView: View {
    let onKey: (RemoteKey) -> Void

    var body: some View {
        VStack(spacing: 8) {
            arrow(.up, "chevron.up", .upArrow, "Up")
            HStack(spacing: 8) {
                arrow(.left, "chevron.left", .leftArrow, "Left")
                Button {
                    onKey(.ok)
                } label: {
                    Text("OK")
                        .font(Theme.heading(15, weight: .bold))
                        .frame(width: 66, height: 66)
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
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 66, height: 44)
        }
        .buttonStyle(RemoteTileStyle())
        .keyboardShortcut(shortcut, modifiers: [])
        .accessibilityLabel(label)
    }
}
