//
//  Theme.swift
//  SplitPay
//
//  Created by Dinh Long on 17/9/26.
//

import Foundation
import SwiftUI

enum Theme {
    enum Colors {
        static let accent = Color(red: 0.78, green: 0.98, blue: 0.42)
        static let background = Color(uiColor: .systemGroupedBackground)
        static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let success = Color.green
        static let badgeTeal = Color(red: 0.0, green: 0.6, blue: 0.6)       
    }

    enum Radius {
        static let card: CGFloat = 20
        static let chip: CGFloat = 16
        static let button: CGFloat = 28
        static let badge: CGFloat = 12
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }

    enum Typography {
        static let amountLarge = Font.system(size: 40, weight: .bold, design: .rounded)
        static let title = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
    }
}
