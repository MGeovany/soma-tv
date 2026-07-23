import SwiftUI

/// Primary action: horizontal Samsung-blue gradient with a soft glow.
/// (White text is used for legibility on blue instead of the spec's black.)
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.heading(13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.accentGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Theme.accentGlow, radius: configuration.isPressed ? 4 : 10, y: 2)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Ghost / outline: glass fill with a hairline border. For secondary actions.
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.heading(12, weight: .medium))
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.10 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Glass tile for remote keys. `prominent` renders the accent gradient (OK).
struct RemoteTileStyle: ButtonStyle {
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
        return configuration.label
            .foregroundColor(prominent ? .white : Theme.textPrimary)
            .background(
                shape.fill(prominent
                           ? AnyShapeStyle(Theme.accentGradient)
                           : AnyShapeStyle(Color.white.opacity(configuration.isPressed ? 0.12 : 0.06)))
            )
            .overlay(
                shape.strokeBorder(configuration.isPressed ? AnyShapeStyle(Theme.accentBright.opacity(0.6))
                                                           : AnyShapeStyle(Theme.border),
                                   lineWidth: 1)
            )
            .shadow(color: prominent ? Theme.accentGlow : .clear,
                    radius: prominent ? 8 : 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// A capsule chip. Active state uses the accent gradient; inactive is glass.
struct Chip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.heading(11, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(isActive ? .white : Theme.textMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isActive
                                   ? AnyShapeStyle(Theme.accentGradient)
                                   : AnyShapeStyle(Color.white.opacity(0.06)))
                )
                .overlay(
                    Capsule().strokeBorder(isActive ? Color.clear : Theme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
