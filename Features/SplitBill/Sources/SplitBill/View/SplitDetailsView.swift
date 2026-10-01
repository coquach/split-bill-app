//
//  SplitDetailsView.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct SplitDetailsView: View {
    @State private var viewModel: SplitDetailsViewModel
    private let onBack: () -> Void
    private let onDownloadQR: (UUID) -> Void
    private let onEdit: (SplitBillDetail) -> Void

    public init(
        viewModel: SplitDetailsViewModel,
        onBack: @escaping () -> Void,
        onDownloadQR: @escaping (UUID) -> Void,
        onEdit: @escaping (SplitBillDetail) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onDownloadQR = onDownloadQR
        self.onEdit = onEdit
    }

    public var body: some View {
        ScrollView {
            content
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split Detail", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomActions }
        .navigationBarHidden(true)
        .screenLifecycle("SplitDetails")
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.huge)

        case .loaded(let loaded):
            VStack(spacing: AppSpacing.lg) {
                StatusBadge(
                    text: viewModel.statusText(loaded),
                    style: loaded.detail.splitBill.status == .active
                        ? .neutral
                        : .success
                )

                Text("-\(viewModel.money(loaded.detail.splitBill.totalAmount))")
                    .font(AppTypography.display)
                    .foregroundStyle(Color.appError)

                infoCard(loaded)
                progressCard(loaded)
                participantsCard(loaded)
            }

        case .failed(let error):
            VStack(spacing: AppSpacing.lg) {
                AlertBanner(message: error.message, style: .error)
                AppButton(title: "Try Again", style: .primary) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private func infoCard(_ loaded: SplitDetailsViewModel.Loaded) -> some View {
        let bill = loaded.detail.splitBill

        return DividedInfoStack([
            .init(label: "Transaction ID", value: loaded.detail.transactionRef),
            .init(label: "Title", value: bill.title),
            .init(label: "Description", value: bill.note?.isEmpty == false ? bill.note! : "—"),
            .init(label: "Date", value: viewModel.paidAtText(from: bill.createdAt)),
        ])
        .padding(AppSpacing.md)
        .background(Color.appSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private func progressCard(_ loaded: SplitDetailsViewModel.Loaded) -> some View {
        let bill = loaded.detail.splitBill

        return VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Paid \(loaded.paidRepayments.count) of \(bill.requiredSlots)")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Text("\(viewModel.money(bill.perPersonAmount)) each")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            LinearProgressBar(progress: viewModel.progress(loaded))

            Rectangle()
                .fill(Color.appBorderDefault)
                .frame(height: 1)

            HStack(alignment: .top) {
                summary(
                    label: "Total",
                    value: viewModel.money(bill.totalAmount),
                    valueColor: Color.appTextPrimary
                )
                Spacer()
                summary(
                    label: "Collected",
                    value: viewModel.money(viewModel.collected(loaded)),
                    // The one green number on the screen — money already in.
                    valueColor: Color.appSuccess
                )
                Spacer()
                summary(
                    label: "Remaining",
                    value: viewModel.money(viewModel.remaining(loaded)),
                    valueColor: Color.appTextPrimary
                )
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private func summary(
        label: String,
        value: String,
        valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(AppTypography.label)
                .foregroundStyle(valueColor)
        }
    }

    private func participantsCard(
        _ loaded: SplitDetailsViewModel.Loaded
    ) -> some View {
        let pending = viewModel.pendingCount(loaded)

        return VStack(spacing: 0) {
            ForEach(loaded.paidRepayments.indices, id: \.self) { index in
                if index > 0 { hairline }

                let repayment = loaded.paidRepayments[index]
                ParticipantRow(
                    name: repayment.payerDisplayName,
                    subtitle: viewModel.paidAtText(repayment),
                    statusText: "Paid",
                    statusStyle: .success
                )
            }

            if pending > 0 {
                if !loaded.paidRepayments.isEmpty { hairline }
                PendingParticipantsRow(count: pending)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .background(Color.appSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private var hairline: some View {
        Rectangle()
            .fill(Color.appBorderDefault)
            .frame(height: 1)
    }

    @ViewBuilder
    private var bottomActions: some View {
        // Get QR and Edit belong to whoever created the split, not to people who paid into it
        if case .loaded(let loaded) = viewModel.state, loaded.detail.isRequester {
            BottomActionBar(
                primary: .init(
                    title: "Get QR",
                    style: .primary,
                    icon: "arrow.down.circle"
                ) {
                    onDownloadQR(loaded.detail.splitBill.id)
                },
                secondary: .init(
                    title: "Edit",
                    style: .secondary,
                    icon: "pencil",
                    isEnabled: loaded.detail.canUpdate
                ) {
                    onEdit(loaded.detail)
                },
                layout: .sideBySide
            )
        }
    }
}
