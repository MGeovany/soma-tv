import SwiftUI

/// Near-black canvas with a single soft lift — no colored glows.
struct MinimalPanelBackground: View {
    var body: some View {
        ZStack {
            Theme.canvas
            RadialGradient(
                colors: [Color.white.opacity(0.035), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }
}

/// Near-black canvas with soft blue radial glows — used in the main window only.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Theme.canvas
            glow(Theme.accent.opacity(0.08),         at: UnitPoint(x: 0.15, y: 0.10), radius: 320)
            glow(Theme.accentBright.opacity(0.05),   at: UnitPoint(x: 0.85, y: 0.20), radius: 280)
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

/// Translucent sidebar panel — lighter than cards so the ambient bg shows through.
struct GlassRailBackground: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(.ultraThinMaterial)
            Rectangle().fill(Theme.glassGradient.opacity(0.55))
            Rectangle().fill(Color.white.opacity(0.025))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Theme.border.opacity(0.35), Theme.border.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
        }
    }
}

/// Frosted-glass surface for buttons and tiles. `accent` tints the glass blue
/// for primary actions; neutral keeps the same look as cards.
struct GlassButtonBackground: View {
    var cornerRadius: CGFloat = 8
    var accent: Bool = false
    var pressed: Bool = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape.fill(.ultraThinMaterial)

            if accent {
                shape.fill(Theme.accent.opacity(pressed ? 0.42 : 0.30))
                shape.fill(Theme.accentBright.opacity(pressed ? 0.18 : 0.11))
            } else {
                shape.fill(Color.white.opacity(pressed ? 0.09 : 0.045))
            }
        }
        .overlay(
            shape.strokeBorder(Color.white.opacity(accent ? 0.14 : 0.06), lineWidth: 1)
                .blendMode(.overlay)
        )
        .overlay(
            shape.strokeBorder(
                accent
                    ? Theme.accentBright.opacity(pressed ? 0.55 : 0.38)
                    : (pressed ? Theme.borderStrong : Theme.border),
                lineWidth: 1
            )
        )
        .overlay(alignment: .top) {
            shape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(accent ? 0.28 : 0.14),
                            Color.white.opacity(0.02),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .padding(1)
        }
        .clipShape(shape)
        .shadow(
            color: accent ? Theme.accentGlow.opacity(pressed ? 0.10 : 0.18) : .clear,
            radius: accent ? 6 : 0,
            y: 1
        )
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
                    .fill(.ultraThinMaterial)
            )
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                    .fill(Color.white.opacity(0.05))
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
    let content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(Theme.caption(10, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.4)
                    .foregroundColor(Theme.accentBright)
            }
            content
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

/// A static status dot — used for the connected state.
struct LiveDot: View {
    var color: Color = Theme.success

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.5), radius: 2)
    }
}
