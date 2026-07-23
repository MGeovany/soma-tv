import SwiftUI

/// Primary action: frosted accent glass.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.ui(12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                GlassButtonBackground(
                    cornerRadius: 8,
                    accent: true,
                    pressed: configuration.isPressed
                )
            )
    }
}

/// Ghost / outline: neutral frosted glass for secondary actions.
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.ui(11, weight: .medium))
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                GlassButtonBackground(
                    cornerRadius: 8,
                    pressed: configuration.isPressed
                )
            )
    }
}

/// Glass tile for remote keys. `prominent` uses accent-tinted glass (OK, etc.).
struct RemoteTileStyle: ButtonStyle {
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(prominent ? .white : Theme.textPrimary)
            .background(
                GlassButtonBackground(
                    cornerRadius: Theme.radiusInput,
                    accent: prominent,
                    pressed: configuration.isPressed
                )
            )
    }
}

/// A capsule chip. Active state uses accent glass; inactive is neutral glass.
struct Chip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.ui(11, weight: .medium))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(isActive ? .white : Theme.textMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(GlassButtonBackground(cornerRadius: 999, accent: isActive))
        }
        .buttonStyle(.plain)
    }
}
