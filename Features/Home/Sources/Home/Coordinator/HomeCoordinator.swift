//
//  HomeCoordinator.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import Domains
import Router
import SwiftUI

public enum HomeDestination: Hashable {
    case splitBill
    case transfer
    case transactionHistory
}

public struct HomeCoordinator: View {
    @State private var router = Router()
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            HomeView(
                viewModel: HomeViewModel(
                    profileRepository: dependencies.profileRepository,
                    walletRepository: dependencies.walletRepository,
                    transferRepository: dependencies.transferRepository
                ),
                onNavigateTransfer: {
                    router.navigate(to: HomeDestination.transfer)
                },
                onNavigateSplitBill: {
                    router.navigate(to: HomeDestination.splitBill)
                },
                onNavigateTransactionHistory: {
                    router.navigate(to: HomeDestination.transactionHistory)
                }
            )
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .splitBill:
                    EmptyView()
                    
                case .transfer:
                    EmptyView()
                case .transactionHistory:
                    EmptyView()
                }
            }}
        .environment(router)
    }
}

extension HomeCoordinator {
    public struct Dependencies {
        let profileRepository: IProfileRepository
        let walletRepository: IWalletRepository
        let transferRepository: ITransferRepository

        public init(profileRepository: IProfileRepository, walletRepository: IWalletRepository, transferRepository: ITransferRepository) {
            self.profileRepository = profileRepository
            self.walletRepository = walletRepository
            self.transferRepository = transferRepository
        }
    }
}
