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
    @Namespace private var categoryNamespace
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
        // categoryPicker sits outside the ScrollView so only the split list
        // underneath it scrolls - the picker stays fixed at the top.
        VStack(spacing: 0) {
            categoryPicker
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

            ScrollView {
                content
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxl)
                    .id(viewModel.selectedCategory)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategory)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split Bills", onBack: onBack)
        }
        .navigationBarHidden(true)
        .screenLifecycle("SplitHistory")
        .task { await viewModel.load() }
    }

    // Segmented control filtering the list by Active / Inactive. The
    // highlight capsule slides between labels via matchedGeometryEffect
    // instead of just popping into place.
    private var categoryPicker: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(SplitHistoryViewModel.Category.allCases, id: \.self) { category in
                let isSelected = viewModel.selectedCategory == category

                Button {
                    viewModel.select(category)
                } label: {
                    Text(category.rawValue)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(
                            isSelected ? Color.appTextOnPrimary : Color.appTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xs)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.appPrimary)
                                    .matchedGeometryEffect(id: "selectedCategory", in: categoryNamespace)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.xxs)
        .background(Color.appSurfaceSecondary)
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(Color.appPrimary, lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategory)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.huge)

        case .loaded:
            let bills = viewModel.visibleBills
            if bills.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: viewModel.selectedCategory == .active
                        ? "No active splits"
                        : "No inactive splits",
                    message: viewModel.selectedCategory == .active
                        ? "Split a completed transaction to start collecting from the people you paid for."
                        : "Splits that are settled, expired, or cancelled will show up here."
                )
            } else {
                billsList(bills)
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

    private func billsList(_ bills: [SplitBillListItem]) -> some View {
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
                        statusStyle: statusStyle(for: bills[index])
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

    private func statusStyle(for bill: SplitBillListItem) -> StatusBadge.Style {
        switch bill.status {
        case .active: return .neutral
        case .closed: return .success
        case .expired: return .pending
        case .cancelled: return .failed
        }
    }
}
