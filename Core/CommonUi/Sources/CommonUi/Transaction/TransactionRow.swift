//
//  TransactionRow.swift
//  CommonUi
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

public struct TransactionRow: View {

    public let title: String
    public let subtitle: String
    public let amount: String
    public let dateText: String
    public let isIncoming: Bool

    public init(
        title: String,
        subtitle: String,
        amount: String,
        dateText: String,
        isIncoming: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.dateText = dateText
        self.isIncoming = isIncoming
    }

    public var body: some View {
        HStack(
            spacing: AppSpacing.sm
        ) {

            icon

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text(title)
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color.appTextPrimary
                    )
                    .lineLimit(1)

                Text(subtitle)
                    .font(
                        .system(size: 12)
                    )
                    .foregroundStyle(
                        Color.appTextTertiary
                    )
                    .lineLimit(1)
            }

            Spacer(
                minLength: AppSpacing.xs
            )

            VStack(
                alignment: .trailing,
                spacing: 2
            ) {
                Text(amount)
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        isIncoming
                            ? Color.appSuccess
                            : Color.appError
                    )

                Text(dateText)
                    .font(
                        .system(size: 11)
                    )
                    .foregroundStyle(
                        Color.appTextTertiary
                    )
            }
        }
    }

    private var icon: some View {
        Circle()
            .fill(
                isIncoming
                    ? Color.appSuccessBackground
                    : Color.appWarningBackground
            )
            .frame(
                width: 44,
                height: 44
            )
            .overlay {
                Image(
                    systemName:
                        isIncoming
                        ? "arrow.down.left"
                        : "arrow.up.right"
                )
                .font(
                    .system(
                        size: 16,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    isIncoming
                        ? Color.appSuccess
                        : Color.appWarning
                )
            }
    }
}
