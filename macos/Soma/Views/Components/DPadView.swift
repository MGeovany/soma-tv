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
                Button("OK") { onKey(.ok) }
                    .frame(width: 66, height: 66)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [])
                arrow(.right, "chevron.right", .rightArrow, "Right")
            }
            arrow(.down, "chevron.down", .downArrow, "Down")
        }
    }

    private func arrow(_ key: RemoteKey, _ symbol: String, _ shortcut: KeyEquivalent, _ label: LocalizedStringKey) -> some View {
        Button { onKey(key) } label: {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 66, height: 44)
        }
        .buttonStyle(.bordered)
        .keyboardShortcut(shortcut, modifiers: [])
        .accessibilityLabel(label)
    }
}
