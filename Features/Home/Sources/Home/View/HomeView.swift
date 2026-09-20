//
//  HomeView.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import SystemDesign

public struct HomeView: View {

        @State private var viewModel: HomeViewModel
    
        public init(viewModel: HomeViewModel) {
            _viewModel = State(initialValue: viewModel)
        }

    public var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xl
            ) {
                HomeHeader(
                    userName: HomeMockData.userName
                )

                BalanceCard(
                    balance: HomeMockData.balance,
                    lastFourDigits: HomeMockData.lastFourDigits
                )

                quickActions

                recentTransactions

                                 AppButton(
                                     title: "Log out",
                                     style: .primary,
                                     isLoading: viewModel.isLoggingOut
                                 ) {
                                     Task {
                                         await viewModel.logout()
                                     }
                                 }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
    }
    private var quickActions: some View {
        HStack(
            spacing: AppSpacing.md
        ) {
            QuickActionCard(
                kind: .transfer
            ) {}
            .frame(maxWidth: .infinity)
            .layoutPriority(2)

            QuickActionCard(
                kind: .split
            ) {}
            .frame(maxWidth: .infinity)

            QuickActionCard(
                kind: .request
            ) {}
            .frame(maxWidth: .infinity)
        }
        .frame(height: 178)
    }

    private var recentTransactions: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.md
        ) {
            HStack {
                Text("Recent Transactions")
                    .font(AppTypography.title)
                    .foregroundStyle(
                        Color.appOnSurface
                    )

                Spacer()

                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")

                        Image(systemName: "chevron.right")
                    }
                    .font(AppTypography.label)
                    .foregroundStyle(
                        Color.appPrimary
                    )
                }
            }

            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(
                    HomeMockData.transactions
                ) { transaction in
                    RecentTransactionRow(
                        transaction: transaction
                    )
                }
            }
        }
    }
}


