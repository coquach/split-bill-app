//
//  HomeCoordinator.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import Domains
import SwiftUI

public struct HomeCoordinator: View {
    private let dependencies: Dependencies
    private let onTransfer: () -> Void
    private let onSplitBill: () -> Void
    private let onTransactionHistory: () -> Void

    public init(
        dependencies: Dependencies,
        onTransfer: @escaping () -> Void = {},
        onSplitBill: @escaping () -> Void = {},
        onTransactionHistory: @escaping () -> Void = {}
    ) {
        self.dependencies = dependencies
        self.onTransfer = onTransfer
        self.onSplitBill = onSplitBill
        self.onTransactionHistory = onTransactionHistory
    }

    public var body: some View {
        NavigationStack {
            HomeView(
                viewModel: HomeViewModel(
                    profileRepository: dependencies.profileRepository,
                    walletRepository: dependencies.walletRepository,
                    transferRepository: dependencies.transferRepository
                ),
                onNavigateTransfer: onTransfer,
                onNavigateSplitBill: onSplitBill,
                onNavigateTransactionHistory: onTransactionHistory
            )
        }
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
