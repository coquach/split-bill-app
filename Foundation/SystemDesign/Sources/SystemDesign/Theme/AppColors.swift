//
//  AppColors.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public extension Color {

    /// Page background
    /// #EFEEEA
    static let appBackground =
        Color("Background", bundle: .module)

    /// Surface / card / input
    /// #FFFFFF
    static let appSurface =
        Color("Surface", bundle: .module)

    /// Dark UI tone - primary text, icons, focus borders, dark button fills
    /// #2E3138
    static let appOnSurface =
        Color("OnSurface", bundle: .module)

    /// Brand / primary
    static let appPrimary =
        Color("Primary", bundle: .module)

    /// Main accent / CTA
    static let appPrimaryContainer =
        Color("PrimaryContainer", bundle: .module)

    /// Secondary / caption text
    /// #9B9B9E
    static let appSecondary =
        Color("Secondary", bundle: .module)

    /// Positive / success accent
    /// #43A047
    static let appSuccess =
        Color("Success", bundle: .module)

    /// Error
    static let appError =
        Color("Error", bundle: .module)

    /// Info pill background (e.g. "Available balance" callout) - a narrow,
    /// deliberate exception to the neutral+mint palette, not a general accent.
    /// #E6EEFC
    static let appInfoContainer =
        Color("InfoContainer", bundle: .module)

    /// Info pill text - pairs with appInfoContainer only.
    /// #1E3677
    static let appInfo =
        Color("Info", bundle: .module)

    /// Icon badge circle background (e.g. the shield badge on PIN verification).
    /// #EFEFEF
    static let appIconBadge =
        Color("IconBadge", bundle: .module)

    /// Custom numeric keypad tray background - distinct from the page background.
    /// #D1D3D9
    static let appKeypadTray =
        Color("KeypadTray", bundle: .module)
}
