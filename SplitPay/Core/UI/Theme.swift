import SwiftUI

/// Design tokens from the UI spec (`ui-spec-transfer-to-split.md`), updated for Liquid
/// Glass (iOS 26 SDK). With Liquid Glass, solid card/button backgrounds are mostly
/// replaced by `.glassEffect(_:in:)` — the system renders the translucency, refraction and
/// light response, not a flat color — so `Colors.surface`/`Colors.primary` below are kept
/// as **tint** inputs to that effect (and as plain-color fallbacks for anything that
/// deliberately stays opaque, like status pill backgrounds) rather than as literal fills.
///
/// Minimum deployment target for this target is iOS 26.0, so Liquid Glass APIs are used
/// directly with no `if #available` branching — see README.md §1.
enum Theme {

    enum Colors {
        static let primary = Color(red: 0.19, green: 0.22, blue: 0.10)       // glass tint — primary buttons
        static let accent = Color(red: 0.78, green: 1.0, blue: 0.24)         // lime — label/icon on primary glass
        static let background = Color(red: 0.96, green: 0.96, blue: 0.94)    // cream screen background (glass sits on top of this)
        static let surface = Color.white                                     // fallback fill for the rare non-glass surface
        static let primaryText = Color(red: 0.11, green: 0.11, blue: 0.11)
        static let secondaryText = Color(red: 0.45, green: 0.45, blue: 0.45)
        static let success = Color(red: 0.20, green: 0.70, blue: 0.45)
        static let warning = Color(red: 0.85, green: 0.60, blue: 0.10)
        static let error = Color(red: 0.80, green: 0.25, blue: 0.20)
        static let divider = Color.black.opacity(0.08)
        static let avatarBackground = Color(red: 0.85, green: 0.85, blue: 0.95)
    }

    enum Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold)
        static let title = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let amount = Font.system(size: 40, weight: .heavy, design: .rounded)
        static let amountMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    }

    enum Spacing {
        static let unit: CGFloat = 4
        static let screenPadding: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let rowMinHeight: CGFloat = 56
        /// Passed to `GlassEffectContainer(spacing:)` when a screen stacks several glass
        /// cards — keeps their edges close enough that the system can blend/morph them as
        /// one coherent glass surface rather than rendering each in isolation.
        static let glassContainerSpacing: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 28
        static let pill: CGFloat = 100
    }

    enum Shape {
        static var card: RoundedRectangle { RoundedRectangle(cornerRadius: Radius.card, style: .continuous) }
        static var button: RoundedRectangle { RoundedRectangle(cornerRadius: Radius.button, style: .continuous) }
    }
}
