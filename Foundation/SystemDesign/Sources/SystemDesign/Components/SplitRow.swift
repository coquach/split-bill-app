//
//  SplitRow.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct SplitRow: View {
    private let title: String
    private let subtitle: String
    private let amountText: String
    private let statusText: String
    private let statusStyle: StatusBadge.Style

    public init(
        title: String,
        subtitle: String,
        amountText: String,
        statusText: String,
        statusStyle: StatusBadge.Style
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amountText = amountText
        self.statusText = statusText
        self.statusStyle = statusStyle
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Avatar(name: title, size: .medium)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
            }

            Spacer()


            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                Text(amountText)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                StatusBadge(text: statusText, style: statusStyle)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
