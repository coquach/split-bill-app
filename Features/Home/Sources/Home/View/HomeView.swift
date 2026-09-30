//
//  HomeView.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import Domains
import SystemDesign

public struct HomeView: View {

    @State
    private var viewModel: HomeViewModel

    private let onNavigateTransfer: () -> Void
    private let onNavigateSplitBill: () -> Void
//    private let onSettings: () -> Void
    private let onNavigateTransactionHistory: () -> Void

    public init(
        viewModel: HomeViewModel,
        onNavigateTransfer: @escaping () -> Void = {},
        onNavigateSplitBill: @escaping () -> Void = {},
//        onSettings: @escaping () -> Void = {},
        onNavigateTransactionHistory: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)

        self.onNavigateTransfer = onNavigateTransfer
        self.onNavigateSplitBill = onNavigateSplitBill
//        self.onSettings = onSettings
        self.onNavigateTransactionHistory = onNavigateTransactionHistory
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            content
            GeometryReader { geo in
                Color.clear
                    .onAppear { print("[DEBUG] HomeView ZStack proposed size: \(geo.size)") }
                    .onChange(of: geo.size) { _, newValue in

                    }
            }
        }
        .background(
            Color.appBackground
                .ignoresSafeArea()
        )
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: {
                    if !$0 {
                        viewModel.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.wallet == nil {
            HomeSkeletonView()
        } else {
            // Only HomeRecentTransactions scrolls internally - everything
            // above it is fixed, so the page itself never scrolls as a whole.
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xl
            ) {
                HomeProfileHeader(
                    displayName: viewModel.displayName,
//                    onSettings: onSettings
                )

                HomeBalanceCard(
                    balance: viewModel.formattedBalance,
                    currency: viewModel.currency,
                    lastFourDigits: viewModel.lastFourWalletDigits,
                    holderName: viewModel.walletHolderName
                )

                // Grouped so these two sit close together; the buttons' own padding already leaves some room
                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {
                    HomeQuickActions(
                        onTransfer: onNavigateTransfer,
                        onSplit: onNavigateSplitBill
                    )

                    HomeRecentTransactions(
                        transactions: viewModel.recentTransfers,
                        isLoading: viewModel.isLoading,
                        onSeeAll: onNavigateTransactionHistory
                    )
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.huge)
            // Without this the VStack hugs its children's ideal height
            // instead of claiming the screen height ZStack proposes to it,
            // so HomeRecentTransactions never gets leftover space to expand into.
            .frame(maxHeight: .infinity, alignment: .top)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { print("[DEBUG] content VStack resolved size: \(geo.size)") }
                        .onChange(of: geo.size) { _, newValue in
                            print("[DEBUG] content VStack resolved size changed: \(newValue)")
                        }
                }
            )
        }
    }
}
