//
//  AppColors.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public extension Color {

    // MARK: - Brand

    /// #3368A0
    static let appPrimary = Color(hex: 0x3368A0)

    /// #66A3BF
    static let appSecondary = Color(hex: 0x66A3BF)

    /// #C8DFDB
    static let appSubtle = Color(hex: 0xC8DFDB)

    /// #F2EFE7
    static let appBackground = Color(hex: 0xF2EFE7)


    // MARK: - Text

    /// #1F2933
    static let appTextPrimary = Color(hex: 0x1F2933)

    /// #52606D
    static let appTextSecondary = Color(hex: 0x52606D)

    /// #7B8794
    static let appTextTertiary = Color(hex: 0x7B8794)

    /// #9AA5B1
    static let appTextPlaceholder = Color(hex: 0x9AA5B1)

    /// #FFFFFF
    static let appTextOnPrimary = Color(hex: 0xFFFFFF)


    // MARK: - Surface

    /// #FFFFFF
    static let appSurfacePrimary = Color(hex: 0xFFFFFF)

    /// #F2EFE7
    static let appSurfaceSecondary = Color(hex: 0xF2EFE7)

    /// #C8DFDB
    static let appSurfaceBrand = Color(hex: 0xC8DFDB)


    // MARK: - Border

    /// #D9DEE3
    static let appBorderDefault = Color(hex: 0xD9DEE3)

    /// #C4CBD2
    static let appBorderStrong = Color(hex: 0xC4CBD2)

    /// #3368A0
    static let appBorderFocus = Color(hex: 0x3368A0)


    // MARK: - Semantic

    /// #4F9D82
    static let appSuccess = Color(hex: 0x4F9D82)

    /// #E5F2ED
    static let appSuccessBackground = Color(hex: 0xE5F2ED)

    /// #D49A4A
    static let appWarning = Color(hex: 0xD49A4A)

    /// #FBF0DD
    static let appWarningBackground = Color(hex: 0xFBF0DD)

    /// #C96B6B
    static let appError = Color(hex: 0xC96B6B)

    /// #F8E7E7
    static let appErrorBackground = Color(hex: 0xF8E7E7)

    /// #5D8FB8
    static let appInfo = Color(hex: 0x5D8FB8)

    /// #E7F0F7
    static let appInfoBackground = Color(hex: 0xE7F0F7)
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
