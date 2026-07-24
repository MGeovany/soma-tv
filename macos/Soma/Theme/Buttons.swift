import SwiftUI

/// Dims a control when it is disabled so glass button styles visibly reflect
/// their `.disabled(...)` state (SwiftUI does not do this automatically for
/// custom `ButtonStyle`s).
private struct DisabledDim: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? 1 : 0.38)
            .saturation(isEnabled ? 1 : 0.4)
    }
}

private extension View {
    func dimWhenDisabled() -> some View { modifier(DisabledDim()) }
}

/// Plays a mechanical "click" the moment a control becomes pressed. Only fires
/// while the control is enabled.
private struct PressSound: ViewModifier {
    let pressed: Bool
    @Environment(\.isEnabled) private var isEnabled

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            content.onChange(of: pressed) { _, now in fire(now) }
        } else {
            content.onChange(of: pressed) { now in fire(now) }
        }
    }

    private func fire(_ now: Bool) {
        if now && isEnabled { SoundEffects.shared.play(.click) }
    }
}

/// Plays a soft "tick" when the pointer moves onto a control (macOS / iPad
/// pointer). Only fires while the control is enabled.
private struct HoverSound: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        content.onHover { hovering in
            if hovering && isEnabled { SoundEffects.shared.play(.hover) }
        }
    }
}

private extension View {
    /// Adds keyboard-style press + hover sound feedback to a control.
    func keyboardSound(pressed: Bool) -> some View {
        modifier(PressSound(pressed: pressed)).modifier(HoverSound())
    }
}

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
            .dimWhenDisabled()
            .keyboardSound(pressed: configuration.isPressed)
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
            .dimWhenDisabled()
            .keyboardSound(pressed: configuration.isPressed)
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
            .dimWhenDisabled()
            .keyboardSound(pressed: configuration.isPressed)
    }
}

/// A capsule chip. Active state uses accent glass; inactive is neutral glass.
struct Chip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            SoundEffects.shared.play(.click)
            action()
        } label: {
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
        .onHover { if $0 { SoundEffects.shared.play(.hover) } }
    }
}
