//
//  SplitHistoryView.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct SplitHistoryView: View {
    @State private var viewModel: SplitHistoryViewModel
    private let onBack: () -> Void
    private let onSelect: (SplitBillListItem) -> Void

    public init(
        viewModel: SplitHistoryViewModel,
        onBack: @escaping () -> Void,
        onSelect: @escaping (SplitBillListItem) -> Void
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
                .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split Bills", onBack: onBack)
        }
        .navigationBarHidden(true)
        .screenLifecycle("SplitHistory")
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.huge)

        case .loaded(let active, let settled):
            if active.isEmpty && settled.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No split bills yet",
                    message: "Split a completed transaction to start collecting from the people you paid for."
                )
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    if !active.isEmpty {
                        section(title: "Active", bills: active)
                    }
                    if !settled.isEmpty {
                        section(title: "Settled", bills: settled)
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

    private func section(title: String, bills: [SplitBillListItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(Color.appTextSecondary)

            VStack(spacing: 0) {
                ForEach(bills.indices, id: \.self) { index in
                    if index > 0 {
                        Rectangle()
                            .fill(Color.appBorderDefault)
                            .frame(height: 1)
                    }

                    Button {
                        onSelect(bills[index])
                    } label: {
                        SplitRow(
                            title: bills[index].title,
                            subtitle: viewModel.subtitle(for: bills[index]),
                            amountText: viewModel.amountText(for: bills[index]),
                            statusText: viewModel.statusText(for: bills[index]),
                            statusStyle: bills[index].status == .active
                                ? .neutral
                                : .success
                        )
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
}
