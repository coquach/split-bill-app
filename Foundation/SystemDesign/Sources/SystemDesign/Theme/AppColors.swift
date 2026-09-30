//
//  AppColors.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public extension Color {

    // MARK: - Brand

    /// #4B7AAB
    static let appPrimary = Color(hex: 0x4B7AAB)

    /// #2B5C94 - deeper than appPrimary, for the primary button fill
    static let appPrimaryBold = Color(hex: 0x2B5C94)

    /// #85B5CC
    static let appSecondary = Color(hex: 0x85B5CC)

    /// #DBEAE8
    static let appSubtle = Color(hex: 0xDBEAE8)

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

    /// #DBEAE8
    static let appSurfaceBrand = Color(hex: 0xDBEAE8)


    // MARK: - Border

    /// #E4E8EB
    static let appBorderDefault = Color(hex: 0xE4E8EB)

    /// #D6DBE0
    static let appBorderStrong = Color(hex: 0xD6DBE0)

    /// #4B7AAB
    static let appBorderFocus = Color(hex: 0x4B7AAB)


    // MARK: - Semantic

    /// #64A991
    static let appSuccess = Color(hex: 0x64A991)

    /// #EFF7F4
    static let appSuccessBackground = Color(hex: 0xEFF7F4)

    /// #D9A660
    static let appWarning = Color(hex: 0xD9A660)

    /// #FDF6EB
    static let appWarningBackground = Color(hex: 0xFDF6EB)

    /// #CF7D7D
    static let appError = Color(hex: 0xCF7D7D)

    /// #FBF1F1
    static let appErrorBackground = Color(hex: 0xFBF1F1)

    /// #75A0C3
    static let appInfo = Color(hex: 0x75A0C3)

    /// #F1F6FA
    static let appInfoBackground = Color(hex: 0xF1F6FA)

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
    /// #E3E5E8 - custom numeric keypad tray background, no equivalent yet.
    static let appKeypadTray = Color(hex: 0xE3E5E8)
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
