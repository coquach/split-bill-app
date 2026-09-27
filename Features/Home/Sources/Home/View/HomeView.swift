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

    private let onTransfer: () -> Void
    private let onSplit: () -> Void
    private let onProfile: () -> Void
//    private let onSettings: () -> Void
    private let onSeeAll: () -> Void

    public init(
        viewModel: HomeViewModel,
        onTransfer: @escaping () -> Void = {},
        onSplit: @escaping () -> Void = {},
        onProfile: @escaping () -> Void = {},
        onSettings: @escaping () -> Void = {},
        onSeeAll: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)

        self.onTransfer = onTransfer
        self.onSplit = onSplit
        self.onProfile = onProfile
//        self.onSettings = onSettings
        self.onSeeAll = onSeeAll
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            content

            HomeFloatingNavigation(
                onSplit: onSplit,
                onProfile: onProfile
            )
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
            ScrollView(showsIndicators: false) {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.xl
                ) {
                    HomeProfileHeader(
                        displayName: viewModel.displayName,
//                        onSettings: onSettings
                    )

                    HomeBalanceCard(
                        balance: viewModel.formattedBalance,
                        currency: viewModel.currency,
                        lastFourDigits: viewModel.lastFourWalletDigits,
                        holderName: viewModel.walletHolderName
                    )

                    HomeQuickActions(
                        onTransfer: onTransfer,
                        onSplit: onSplit
                    )

                    HomeRecentTransactions(
                        transactions: viewModel.recentTransfers,
                        isLoading: viewModel.isLoading,
                        onSeeAll: onSeeAll
                    )
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
        }
    }
}
