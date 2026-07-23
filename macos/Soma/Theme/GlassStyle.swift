import SwiftUI

/// Near-black canvas with soft blue radial glows — the "ambient-bg" from the
/// spec. Placed at the back of every window/panel.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Theme.canvas
            glow(Theme.accent.opacity(0.20),      at: UnitPoint(x: 0.12, y: 0.08), radius: 460)
            glow(Theme.accentBright.opacity(0.12), at: UnitPoint(x: 0.88, y: 0.18), radius: 420)
            glow(Theme.accent.opacity(0.14),      at: UnitPoint(x: 0.50, y: 1.00), radius: 520)
        }
        .ignoresSafeArea()
    }

    private func glow(_ color: Color, at point: UnitPoint, radius: CGFloat) -> some View {
        RadialGradient(colors: [color, .clear],
                       center: point, startRadius: 0, endRadius: radius)
    }
}

/// Glass surface: a blur, a dark translucent gradient tint, an inset highlight
/// and a border (optionally the accent gradient border for hero cards).
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.radiusCard
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return content
            .background(shape.fill(.ultraThinMaterial))
            .background(shape.fill(Theme.glassGradient))
            .overlay(
                shape.strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    .blendMode(.overlay)
            )
            .overlay(
                shape.strokeBorder(highlighted ? AnyShapeStyle(Theme.gradientBorder)
                                               : AnyShapeStyle(Theme.border),
                                   lineWidth: 1)
            )
            .clipShape(shape)
    }
}

extension View {
    /// Wraps content in a glass card. Use `highlighted` for hero surfaces.
    func glassCard(cornerRadius: CGFloat = Theme.radiusCard,
                   highlighted: Bool = false) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, highlighted: highlighted))
    }

    /// Dark glass styling for text inputs.
    func glassField() -> some View {
        textFieldStyle(.plain)
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}

/// A titled glass card. The label uses the accent-bright uppercase style from
/// the spec's metric cards.
struct SectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder var content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(Theme.heading(11, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundColor(Theme.accentBright)
            }
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

/// A pulsing green "live" dot with a soft glow — used for the connected state.
struct LiveDot: View {
    var color: Color = Theme.success
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.8), radius: pulse ? 5 : 2)
            .scaleEffect(pulse ? 1.0 : 0.82)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
