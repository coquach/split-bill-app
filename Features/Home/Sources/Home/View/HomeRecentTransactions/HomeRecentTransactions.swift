//
//  HomeRecentTransactions.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

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

            // Same card as Transaction History: white, rows split by hairlines. Not scrollable - Home only shows the latest 3.
            VStack(spacing: 0) {
                if isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        TransactionRowSkeleton()
                            .padding(.vertical, AppSpacing.sm)
                    }
                } else if transactions.isEmpty {
                    EmptyTransactionsView()
                } else {
                    ForEach(transactions.indices, id: \.self) { index in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.appBorderDefault)
                                .frame(height: 1)
                        }

                        row(transactions[index])
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .background(Color.appSurfacePrimary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
            )
        }
    }

    private func row(_ transaction: HomeTransaction) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(Color.appSurfaceSecondary)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(
                        systemName: transaction.isIncoming
                            ? "arrow.down.left"
                            : "arrow.up.right"
                    )
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(transaction.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)
                Text(transaction.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Text(transaction.formattedAmount)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(
                    transaction.isIncoming ? Color.appSuccess : Color.appError
                )
        }
        .padding(.vertical, AppSpacing.sm)
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
