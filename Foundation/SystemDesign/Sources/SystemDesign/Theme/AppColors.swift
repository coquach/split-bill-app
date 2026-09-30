//
//  AppColors.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public extension Color {

    // MARK: - Brand

    /// #346699
    static let appPrimary = Color(hex: 0x346699)

    /// #1E4D83 - deeper than appPrimary, for the primary button fill
    static let appPrimaryBold = Color(hex: 0x1E4D83)

    /// #5BA8CD
    static let appSecondary = Color(hex: 0x5BA8CD)

    /// #C1E5E0
    static let appSubtle = Color(hex: 0xC1E5E0)

    /// #F8F7F3
    static let appBackground = Color(hex: 0xF8F7F3)


    // MARK: - Text

    /// #1C1C1E
    static let appTextPrimary = Color(hex: 0x1C1C1E)

    /// #48484A
    static let appTextSecondary = Color(hex: 0x48484A)

    /// #636366
    static let appTextTertiary = Color(hex: 0x636366)

    /// #8E8E93
    static let appTextPlaceholder = Color(hex: 0x8E8E93)

    /// #FFFFFF
    static let appTextOnPrimary = Color(hex: 0xFFFFFF)


    // MARK: - Surface

    /// #FFFFFF
    static let appSurfacePrimary = Color(hex: 0xFFFFFF)

    /// #F8F7F3
    static let appSurfaceSecondary = Color(hex: 0xF8F7F3)

    /// #C1E5E0
    static let appSurfaceBrand = Color(hex: 0xC1E5E0)


    // MARK: - Border

    /// #C7CFD5
    static let appBorderDefault = Color(hex: 0xC7CFD5)

    /// #B9C2CA
    static let appBorderStrong = Color(hex: 0xB9C2CA)

    /// #346699
    static let appBorderFocus = Color(hex: 0x346699)


    // MARK: - Semantic

    /// #44A080
    static let appSuccess = Color(hex: 0x44A080)

    /// #D7F1E7
    static let appSuccessBackground = Color(hex: 0xD7F1E7)

    /// #DF9631
    static let appWarning = Color(hex: 0xDF9631)

    /// #FEEACB
    static let appWarningBackground = Color(hex: 0xFEEACB)

    /// #D15252
    static let appError = Color(hex: 0xD15252)

    /// #F8D6D6
    static let appErrorBackground = Color(hex: 0xF8D6D6)

    /// #4A8EC5
    static let appInfo = Color(hex: 0x4A8EC5)

    /// #D7E8F6
    static let appInfoBackground = Color(hex: 0xD7E8F6)

    // MARK: - Compatibility aliases
    // Bridges older component code (built against a prior token set) onto
    // this palette. Remove a given alias once every call site using it has
    // been migrated to the token above it maps to.

    /// -> appTextPrimary
    static let appOnSurface = appTextPrimary
    /// -> appSurfacePrimary
    static let appSurface = appSurfacePrimary
    /// -> appSubtle
    static let appPrimaryContainer = appSubtle
    /// -> appInfoBackground
    static let appInfoContainer = appInfoBackground
    /// -> appSurfaceSecondary
    static let appIconBadge = appSurfaceSecondary
    /// #D2D5DA - custom numeric keypad tray background, no equivalent yet.
    static let appKeypadTray = Color(hex: 0xD2D5DA)
}


// MARK: - Hex Color

private extension Color {

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
