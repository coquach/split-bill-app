//
//  ParticipantRow.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct ParticipantRow: View {
    private let name: String
    private let subtitle: String?
    private let amountText: String?
    private let statusText: String
    private let statusStyle: StatusBadge.Style

    /// - Parameters:
    ///   - subtitle: e.g. when they paid. Optional so the row works in
    ///     contexts that have no timestamp.
    ///   - amountText: optional for the same reason — on Split Details
    ///     everyone paid the same share, so repeating it per row is noise.
    public init(
        name: String,
        subtitle: String? = nil,
        amountText: String? = nil,
        statusText: String,
        statusStyle: StatusBadge.Style
    ) {
        self.name = name
        self.subtitle = subtitle
        self.amountText = amountText
        self.statusText = statusText
        self.statusStyle = statusStyle
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Avatar(name: name, size: .small)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            if let amountText {
                Text(amountText)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)
            }

            StatusBadge(text: statusText, style: statusStyle)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
