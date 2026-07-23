import SwiftUI

/// Flat near-black canvas — minimal, no gradients.
struct MinimalPanelBackground: View {
    var body: some View {
        Theme.canvas.ignoresSafeArea()
    }
}

/// Flat near-black canvas for the main shell — minimal, no colored glows.
struct AmbientBackground: View {
    var body: some View {
        Theme.canvas.ignoresSafeArea()
    }
}

/// Flat glass surface: a blur, a single flat tint and a thin hairline border.
/// No gradients or inset highlights — a clean, modern minimal panel.
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.radiusCard
    var highlighted: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return content
            .background(shape.fill(.ultraThinMaterial))
            .background(shape.fill(Color.white.opacity(0.04)))
            .overlay(
                shape.strokeBorder(
                    highlighted ? Theme.accentBright.opacity(0.45)
                                : Color.white.opacity(0.08),
                    lineWidth: 1
                )
            )
            .clipShape(shape)
    }
}

/// Flat translucent sidebar panel with a hairline trailing divider.
struct GlassRailBackground: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(.ultraThinMaterial)
            Rectangle().fill(Color.white.opacity(0.03))
            Rectangle().fill(Theme.border).frame(width: 1)
        }
    }
}

/// Flat frosted surface for buttons and tiles. `accent` uses a solid blue fill;
/// neutral is a subtle translucent surface. No gradients, highlights or glow.
struct GlassButtonBackground: View {
    var cornerRadius: CGFloat = 8
    var accent: Bool = false
    var pressed: Bool = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            if accent {
                shape.fill(pressed ? Theme.accentHover : Theme.accentBright)
            } else {
                shape.fill(.ultraThinMaterial)
                shape.fill(Color.white.opacity(pressed ? 0.10 : 0.05))
            }
        }
        .overlay(
            shape.strokeBorder(
                accent
                    ? Color.white.opacity(0.12)
                    : (pressed ? Theme.borderStrong : Theme.border),
                lineWidth: 1
            )
        )
        .clipShape(shape)
    }
}

extension View {
    /// Wraps content in a flat glass card. Use `highlighted` for hero surfaces.
    func glassCard(cornerRadius: CGFloat = Theme.radiusCard,
                   highlighted: Bool = false) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, highlighted: highlighted))
    }

    /// Flat dark styling for text inputs.
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

/// A titled glass card. The label uses the accent-bright uppercase style.
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
    }
}
