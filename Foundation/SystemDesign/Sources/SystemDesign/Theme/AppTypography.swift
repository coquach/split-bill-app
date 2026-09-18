//
//  AppTypography.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public enum AppTypography {

    public static let display =
        Font.system(
            size: 32,
            weight: .bold
        )

    public static let title =
        Font.system(
            size: 26,
            weight: .bold
        )

    public static let body =
        Font.system(
            size: 16,
            weight: .regular
        )

    public static let bodyMedium =
        Font.system(
            size: 16,
            weight: .medium
        )

    public static let label =
        Font.system(
            size: 14,
            weight: .semibold
        )

    public static let caption =
        Font.system(
            size: 13,
            weight: .regular
        )
}
