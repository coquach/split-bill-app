//
//  AppColors.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public extension Color {

    /// App background
    /// #F7F9FB
    static let appBackground =
        Color("Background", bundle: .module)

    /// Surface / card / input
    /// #FFFFFF
    static let appSurface =
        Color("Surface", bundle: .module)

    /// Primary text
    /// #191C1E
    static let appOnSurface =
        Color("OnSurface", bundle: .module)

    /// Brand / primary
    /// #506600
    static let appPrimary =
        Color("Primary", bundle: .module)

    /// Main accent / CTA
    /// #CCFF00
    static let appPrimaryContainer =
        Color("PrimaryContainer", bundle: .module)

    /// Secondary text / action
    /// #565E74
    static let appSecondary =
        Color("Secondary", bundle: .module)

    /// Positive / success accent
    /// #006C49
    static let appSuccess =
        Color("Success", bundle: .module)

    /// Error
    /// #BA1A1A
    static let appError =
        Color("Error", bundle: .module)
}
