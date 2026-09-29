//
//  TransactionHistoryView.swift
//  Transfer
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct TransactionHistoryView: View {
    @State private var viewModel: TransactionHistoryViewModel
    private let onBack: (() -> Void)?
    private let onSelect: (TransferHistory) -> Void

    public init(
        viewModel: TransactionHistoryViewModel,
        onBack: (() -> Void)? = nil,
        onSelect: @escaping (TransferHistory) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView {
            content
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                // Clears the tab bar and the floating scan button above it.
                .padding(.bottom, 140)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Transaction History", onBack: onBack)
        }
        .navigationBarHidden(true)
        .screenLifecycle("TransactionHistory")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.huge)

        case .loaded(let sections):
            if sections.isEmpty {
                EmptyStateView(
                    icon: "arrow.left.arrow.right",
                    title: "No transactions yet",
                    message: "Money you send and receive will show up here."
                )
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ForEach(sections) { section in
                        sectionView(section)
                    }
                }
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

    private func sectionView(
        _ section: TransactionHistoryViewModel.Section
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(section.title)
                .font(AppTypography.caption)
                .foregroundStyle(Color.appTextSecondary)

            VStack(spacing: 0) {
                ForEach(section.items.indices, id: \.self) { index in
                    if index > 0 {
                        Rectangle()
                            .fill(Color.appBorderDefault)
                            .frame(height: 1)
                    }

                    Button {
                        onSelect(section.items[index])
                    } label: {
                        row(section.items[index])
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .background(Color.appSurfacePrimary)
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
            )
        }
    }

    private func row(_ item: TransferHistory) -> some View {
        let incoming = viewModel.isIncoming(item)

        return HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(Color.appSurfaceSecondary)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: incoming ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(viewModel.title(for: item))
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)
                Text(viewModel.subtitle(for: item))
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Text(viewModel.amountText(for: item))
                .font(AppTypography.bodyMedium)
                .foregroundStyle(incoming ? Color.appSuccess : Color.appError)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}
