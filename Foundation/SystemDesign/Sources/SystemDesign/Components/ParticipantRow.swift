//
//  ParticipantRow.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct ParticipantRow: View {
    private let name: String
    private let amountText: String   
    private let statusText: String
    private let statusStyle: StatusBadge.Style

    public init(
        name: String,
        amountText: String,
        statusText: String,
        statusStyle: StatusBadge.Style
    ) {
        self.name = name
        self.amountText = amountText
        self.statusText = statusText
        self.statusStyle = statusStyle
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Avatar(name: name, size: .small)

            Text(name)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface)

            Spacer()

            Text(amountText)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface)

            StatusBadge(text: statusText, style: statusStyle)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
