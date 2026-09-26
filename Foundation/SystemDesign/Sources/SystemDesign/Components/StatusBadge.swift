//
//  StatusBadge.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct StatusBadge: View {

    public enum Style {
        case success   // "Paid", "Settled"
        case pending   // "Pending", "Awaiting payment"
        case failed    // "Failed", "Declined"

        var background: Color {
            switch self {
            case .success: return Color.appSuccess.opacity(0.15)
            case .pending: return Color.appPrimaryContainer
            case .failed: return Color.appError.opacity(0.15)
            }
        }

        var foreground: Color {
            switch self {
            case .success: return Color.appSuccess
            case .pending: return Color.appOnSurface
            case .failed: return Color.appError
            }
        }
    }

    private let text: String
    private let style: Style

    public init(text: String, style: Style) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(AppTypography.caption)
            .foregroundStyle(style.foreground)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(style.background)
            .clipShape(Capsule())
    }
}
