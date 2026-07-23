import SwiftUI

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

/// Design tokens — dark glass UI with a neutral system typeface and Samsung blue accent.
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

    /// Flat fills for buttons — no gradients.
    static let buttonFill        = Color(hex: 0x2563AD)
    static let buttonFillPressed = Color(hex: 0x1D4F8C)
    static let buttonBorder      = Color.white.opacity(0.12)

    // MARK: Semantic
    static let link    = Color(hex: 0x2E9BFF)
    static let success = Color(hex: 0x00D973)
    static let error   = Color(hex: 0xF24D4D)
    static let warning = Color(hex: 0xFF9D00)
    static let info    = Color(hex: 0x45D9FF)

    // MARK: Layout
    static let columnWidth: CGFloat = 252
    static let wideColumnWidth: CGFloat = 340
    static let railWidth:   CGFloat = 52
    static let contentPaddingH: CGFloat = 12
    /// Width of the pane to the right of the navigation rail (remote control).
    static var contentPaneWidth: CGFloat { columnWidth + contentPaddingH * 2 }
    /// Wider pane for devices, settings and other text-heavy screens.
    static var wideContentPaneWidth: CGFloat { wideColumnWidth + contentPaddingH * 2 }
    /// Total main-window width for the remote control tab.
    static var windowWidth: CGFloat { railWidth + contentPaneWidth }
    /// Total main-window width for text-heavy tabs.
    static var wideWindowWidth: CGFloat { railWidth + wideContentPaneWidth }

    // MARK: Radii
    static let radiusControl: CGFloat = 4
    static let radiusInput:   CGFloat = 10
    static let radiusCard:    CGFloat = 14
    static let radiusHero:    CGFloat = 18

    // MARK: Fonts
    // SF Pro (system default) for a neutral remote-control feel. Monospaced only
    // for technical values like IPs, timers and channel entry.

    /// Primary UI type: buttons, labels, headings.
    static func ui(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func heading(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        ui(size, weight: weight)
    }

    /// Secondary captions and helper text.
    static func caption(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        ui(size, weight: weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
