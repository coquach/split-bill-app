//
//  TransactionDetailView.swift
//  Transfer
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct TransactionDetailView: View {
    @State private var viewModel: TransactionDetailViewModel
    private let onBack: () -> Void
    private let onSplitBill: () -> Void
    private let onBackToHome: () -> Void

    public init(
        viewModel: TransactionDetailViewModel,
        onBack: @escaping () -> Void,
        onSplitBill: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onSplitBill = onSplitBill
        self.onBackToHome = onBackToHome
    }

    public var body: some View {
        ScrollView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppSpacing.huge)

                case .loaded(let detail):
                    loadedContent(detail)

                case .failed(let error):
                    failedContent(message: error.message)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Transaction Detail", onBack: onBack)
        }
        .navigationBarHidden(true)
        .screenLifecycle("TransactionDetail")
        .task { await viewModel.load() }
    }

    // MARK: - Loaded

    private func loadedContent(_ detail: TransferDetail) -> some View {
        VStack(spacing: AppSpacing.lg) {
            StatusBadge(
                text: statusText(detail.status),
                style: statusStyle(detail.status)
            )

            Text(viewModel.formattedOutgoingAmount(detail.amount))
                .font(AppTypography.display)
                .foregroundStyle(Color.appError)

            InfoCard {
                VStack(spacing: AppSpacing.md) {
                    row(label: "Transaction ID", value: detail.transactionRef)

                    Divider()

                    row(label: "Receiver", value: viewModel.receiverHolderName)

                    Divider()

                    row(
                        label: "Description",
                        // An em dash reads better than a blank gap when the
                        // user sent the transfer without a note.
                        value: detail.description.flatMap {
                            $0.isEmpty ? nil : $0
                        } ?? "—"
                    )

                    Divider()

                    row(
                        label: "Date",
                        value: viewModel.formattedDate(detail.createdAt)
                    )
                }
            }

            VStack(spacing: AppSpacing.sm) {
                // Shown strictly on the backend's answer, never on a rule
                // re-derived here — it knows about ownership, age and
                // whether a split already exists.
                if detail.canCreateSplitBill {
                    AppButton(
                        title: "Split Bill",
                        style: .primary,
                        action: onSplitBill
                    )
                }

                AppButton(
                    title: "Back to Home",
                    style: .accent,
                    action: onBackToHome
                )
            }
        }
    }

    // MARK: - Failed

    private func failedContent(message: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            AlertBanner(message: message, style: .error)

            AppButton(title: "Try Again", style: .primary) {
                Task { await viewModel.load() }
            }

            AppButton(
                title: "Back to Home",
                style: .accent,
                action: onBackToHome
            )
        }
    }

    // MARK: - Pieces

    private func row(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))

            Spacer()

            Text(value)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.trailing)
        }
    }

    private func statusText(_ status: TransferStatus) -> String {
        switch status {
        case .success: return "Completed"
        case .pending: return "Pending"
        case .failed: return "Failed"
        }
    }

    private func statusStyle(_ status: TransferStatus) -> StatusBadge.Style {
        switch status {
        case .success: return .success
        case .pending: return .pending
        case .failed: return .failed
        }
    }
}
