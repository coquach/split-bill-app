//
//  HomeRecentTransactions.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign
import CommonUi

struct HomeRecentTransactions: View {

    let transactions: [HomeTransaction]
    let isLoading: Bool
    let onSeeAll: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {

            HStack {
                Text("Recent Transactions")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(
                        Color.appTextPrimary
                    )

                Spacer()

                Button(
                    "See All",
                    action: onSeeAll
                )
                .font(
                    .system(
                        size: 12,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color.appPrimary
                )
            }
            .padding(
                .horizontal,
                AppSpacing.xs
            )

            VStack(
                spacing: AppSpacing.md
            ) {
                if isLoading {
                    ForEach(
                        0..<4,
                        id: \.self
                    ) { _ in
                        TransactionRowSkeleton()
                    }
                } else if transactions.isEmpty {
                    EmptyTransactionsView()
                } else {
                    ForEach(
                        transactions
                    ) { transaction in
                        TransactionRow(
                            title: transaction.title,
                            subtitle: transaction.subtitle,
                            amount: transaction.formattedAmount,
                            dateText: transaction.dateText,
                            isIncoming: transaction.isIncoming
                        )
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                Color.appSurfacePrimary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.xl,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.xl,
                    style: .continuous
                )
                .stroke(
                    Color.appBorderDefault,
                    lineWidth: 1
                )
            }
        }
    }
}

private struct EmptyTransactionsView: View {

    var body: some View {
        VStack(
            spacing: AppSpacing.xs
        ) {
            Image(
                systemName: "arrow.left.arrow.right"
            )
            .font(
                .system(
                    size: 20,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color.appTextTertiary
            )

            Text("No transactions yet")
                .font(AppTypography.caption)
                .foregroundStyle(
                    Color.appTextSecondary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(
            .vertical,
            AppSpacing.xl
        )
    }
}
