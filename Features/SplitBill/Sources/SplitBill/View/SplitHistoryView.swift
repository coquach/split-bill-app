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
    private let onBack: (() -> Void)?
    private let onSelect: (SplitBillListItem) -> Void

    public init(
        viewModel: SplitHistoryViewModel,
        onBack: (() -> Void)? = nil,
        onSelect: @escaping (SplitBillListItem) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onSelect = onSelect
    }

    public var body: some View {
        // The tabs and the filter sit outside the ScrollView so only the split list
        // underneath them scrolls - they stay fixed at the top.
        VStack(spacing: 0) {
            categoryPicker
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)

            filterChips
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

            ScrollView {
                content
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxl)
                    .id("\(viewModel.selectedKind.rawValue)-\(viewModel.selectedFilter.rawValue)")
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedKind)
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedFilter)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split Bills", onBack: onBack)
        }
        .navigationBarHidden(true)
        .screenLifecycle("SplitHistory")
        .task { await viewModel.load() }
    }

    // Main tabs: Your Split / Split Transfer. The highlight capsule slides
    // between labels via matchedGeometryEffect instead of just popping into place.
    private var categoryPicker: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(SplitHistoryViewModel.Kind.allCases, id: \.self) { kind in
                let isSelected = viewModel.selectedKind == kind

                Button {
                    viewModel.select(kind)
                } label: {
                    Text(kind.rawValue)
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedKind)
    }

    // Small chips under the tabs to filter the list by split status — the
    // same status filter the repository contract declares.
    private var filterChips: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(SplitBillStatusFilter.allCases, id: \.self) { filter in
                let isSelected = viewModel.selectedFilter == filter

                Button {
                    viewModel.select(filter)
                } label: {
                    Text(viewModel.label(for: filter))
                        .font(AppTypography.label)
                        .foregroundStyle(
                            isSelected ? Color.appTextOnPrimary : Color.appTextSecondary
                        )
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            Capsule().fill(
                                isSelected ? Color.appPrimary : Color.appSurfacePrimary
                            )
                        )
                        .overlay {
                            Capsule().strokeBorder(
                                isSelected ? Color.appPrimary : Color.appBorderStrong,
                                lineWidth: 1
                            )
                        }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedFilter)
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
                    title: emptyTitle,
                    message: emptyMessage
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

    private var emptyTitle: String {
        switch viewModel.selectedKind {
        case .yourSplit:
            return statusTitle(item: "splits")
        case .splitTransfer:
            return statusTitle(item: "split transfers")
        }
    }

    private func statusTitle(item: String) -> String {
        switch viewModel.selectedFilter {
        case .all:
            return "No \(item) yet"
        case .active:
            return "No active \(item)"
        case .closed:
            return "No settled \(item)"
        case .expired:
            return "No expired \(item)"
        }
    }

    private var emptyMessage: String {
        switch viewModel.selectedKind {
        case .yourSplit:
            switch viewModel.selectedFilter {
            case .all:
                return "Split a completed transaction to start collecting from the people you paid for."
            case .active:
                return "Splits you create will show up here while they're open."
            case .closed:
                return "Splits you created that are fully paid will show up here."
            case .expired:
                return "Splits that passed their deadline unpaid will show up here."
            }
        case .splitTransfer:
            switch viewModel.selectedFilter {
            case .all:
                return "Splits you pay by scanning a QR code will show up here."
            case .active:
                return "Splits you can pay by scanning a QR code will show up here while they're open."
            case .closed:
                return "Splits you paid that are fully settled will show up here."
            case .expired:
                return "Splits you paid that expired will show up here."
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
                .accessibilityIdentifier("\(UITestID.splitHistoryRowPrefix).\(index)")
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
