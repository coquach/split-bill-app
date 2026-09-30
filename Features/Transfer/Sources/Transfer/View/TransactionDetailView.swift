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
    private let onSplitBill: (SplitSource) -> Void
    private let onViewSplit: (UUID) -> Void
    private let onBackToHome: () -> Void

    public init(
        viewModel: TransactionDetailViewModel,
        onBack: @escaping () -> Void,
        onSplitBill: @escaping (SplitSource) -> Void,
        onViewSplit: @escaping (UUID) -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onSplitBill = onSplitBill
        self.onViewSplit = onViewSplit
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
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomActions }
        .navigationBarHidden(true)
        .screenLifecycle("TransactionDetail")
        .task { await viewModel.load() }
    }

    private func loadedContent(_ detail: TransferDetail) -> some View {
        VStack(spacing: AppSpacing.lg) {
            statusIndicator(detail.status)

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
        }
    }

    private func failedContent(message: String) -> some View {
        AlertBanner(message: message, style: .error)
    }

    @ViewBuilder
    private var bottomActions: some View {
        switch viewModel.state {
        case .loading:
            EmptyView()

        case .loaded(let detail):
            // Linked to a split, either one you created or one you paid into: open it instead of creating another
            if let splitBillId = detail.splitBillId {
                BottomActionBar(
                    primary: .init(title: "View Split", style: .primary) {
                        onViewSplit(splitBillId)
                    },
                    secondary: .init(
                        title: "Back to Home",
                        style: .secondary,
                        handler: onBackToHome
                    )
                )
            } else if detail.canCreateSplitBill {
                BottomActionBar(
                    primary: .init(
                        title: "Split Bill",
                        style: .primary,
                        accessibilityID: UITestID.detailSplitBill
                    ) {
                        onSplitBill(splitSource(for: detail))
                    },
                    secondary: .init(
                        title: "Back to Home",
                        style: .secondary,
                        handler: onBackToHome
                    )
                )
            } else {
                BottomActionBar(
                    primary: .init(
                        title: "Back to Home",
                        style: .primary,
                        handler: onBackToHome
                    )
                )
            }

        case .failed:
            BottomActionBar(
                primary: .init(title: "Try Again", style: .primary) {
                    Task { await viewModel.load() }
                },
                secondary: .init(
                    title: "Back to Home",
                    style: .secondary,
                    handler: onBackToHome
                )
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

    /// Everything the Split module needs about the transaction being split.
    /// The receiver name comes from the receipt this screen was opened with,
    /// since `get_transfer_detail` doesn't return the counterparty.
    private func splitSource(for detail: TransferDetail) -> SplitSource {
        let description = detail.description?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return SplitSource(
            transferId: detail.id,
            // `create_split_bill` requires a title, and a transfer's
            // description is optional — fall back to who it was paid to
            // rather than sending an empty string.
            title: description.isEmpty
                ? viewModel.receiverHolderName
                : description,
            counterpartyName: viewModel.receiverHolderName,
            date: detail.createdAt,
            totalAmount: Amount(Double(detail.amount))
        )
    }

    // A completed transfer shows just the green check; pending and failed keep their text badge
    @ViewBuilder
    private func statusIndicator(_ status: TransferStatus) -> some View {
        if status == .success {
            ZStack {
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Completed")
        } else {
            StatusBadge(
                text: statusText(status),
                style: statusStyle(status)
            )
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
