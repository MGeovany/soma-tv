import SwiftUI
import AppKit

extension Color {
    /// Builds a color from a 0xRRGGBB hex value.
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

/// "Rivalo Glass" design tokens — dark, sporty glassmorphism with Samsung blue
/// as the energetic accent (in place of the original orange). Everything the
/// UI needs (colors, fonts, radii, gradients) lives here so the look stays
/// consistent across every screen.
enum Theme {

    // MARK: Canvas & surfaces
    static let canvas      = Color(hex: 0x040506)
    static let surfaceBase = Color(hex: 0x242526)
    static let surfaceDeep = Color(hex: 0x101112)

    static let glassFill  = Color.white.opacity(0.06)
    static let glassHover = Color.white.opacity(0.10)
    static let border       = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)

    // MARK: Text
    static let textPrimary = Color(hex: 0xF5F5F5)
    static let textMuted   = Color(hex: 0x999999)
    static let textSubtle  = Color(hex: 0x666666)

    // MARK: Accent — Samsung blue
    static let accent       = Color(hex: 0x1428A0) // Samsung signature blue
    static let accentBright = Color(hex: 0x2E9BFF) // bright azure for labels/glow
    static let accentHover  = Color(hex: 0x3FA9FF)
    static let accentSoft    = Color(hex: 0x2E9BFF, alpha: 0.16)
    static let accentGlow    = Color(hex: 0x2E9BFF, alpha: 0.40)

    // MARK: Semantic
    static let link    = Color(hex: 0x2E9BFF)
    static let success = Color(hex: 0x00D973)
    static let error   = Color(hex: 0xF24D4D)
    static let warning = Color(hex: 0xFF9D00)
    static let info    = Color(hex: 0x45D9FF)

    // MARK: Radii
    static let radiusControl: CGFloat = 4
    static let radiusInput:   CGFloat = 12
    static let radiusCard:    CGFloat = 18
    static let radiusHero:    CGFloat = 22

    // MARK: Gradients
    /// Horizontal accent gradient for primary actions and active chips.
    static let accentGradient = LinearGradient(
        colors: [accentBright, accent],
        startPoint: .leading, endPoint: .trailing)

    /// Subtle gradient border for highlighted cards (top-left glow → fade).
    static var gradientBorder: LinearGradient {
        LinearGradient(stops: [
            .init(color: accentBright.opacity(0.45), location: 0.0),
            .init(color: Color.white.opacity(0.04),  location: 0.40),
            .init(color: .clear,                     location: 1.0),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Dark translucent fill layered over a blur to make "almost-black glass".
    static let glassGradient = LinearGradient(
        colors: [surfaceBase.opacity(0.82), surfaceDeep.opacity(0.72)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    // MARK: Fonts
    // Rajdhani (UI/headings) and Space Mono (metrics) if installed; otherwise
    // graceful native fallbacks that keep the sporty / mono feel.
    private static let installedFontFamilies = Set(NSFontManager.shared.availableFontFamilies)
    private static let rajdhaniAvailable = installedFontFamilies.contains("Rajdhani")
    private static let spaceMonoAvailable = installedFontFamilies.contains("Space Mono")

    static func heading(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        if rajdhaniAvailable { return .custom("Rajdhani", size: size).weight(weight) }
        return .system(size: size, weight: weight, design: .rounded)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if spaceMonoAvailable { return .custom("Space Mono", size: size).weight(weight) }
        return .system(size: size, weight: weight, design: .monospaced)
    }
}
