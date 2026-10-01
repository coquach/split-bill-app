//
//  TransferCoordinator.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Router
import SwiftUI

// Two entry points: the send-money flow, and the history list shown as a tab.
public enum TransferEntry: Hashable {
    case flow
    case history
}

public enum TransferDestination: Hashable {
    case confirm
    case otp
    case success
    // isOutgoing drives the amount sign/colour on the detail screen — the
    // detail RPC returns both parties, not who is viewing, so the navigation
    // site (which knows the direction) carries it along.
    case detail(transactionId: UUID, receiverName: String, isOutgoing: Bool)
}

public struct TransferCoordinator: View {
    // Injectable so a parent tab view can hold the same instance across tab switches and reset it to root.
    @Bindable private var router: Router
    private let entry: TransferEntry
    private let dependencies: Dependencies
    private let onFinish: () -> Void
    private let onSplitBill: (SplitSource) -> Void
    private let onViewSplit: (UUID) -> Void

    // Shared across Input, Confirm and OTP so the draft and submission result
    // only ever live in one place - see TransferFlowViewModel.
    @State private var flowViewModel: TransferFlowViewModel

    public init(
        entry: TransferEntry = .flow,
        router: Router = Router(),
        dependencies: Dependencies,
        onFinish: @escaping () -> Void,
        onSplitBill: @escaping (SplitSource) -> Void,
        onViewSplit: @escaping (UUID) -> Void
    ) {
        self.entry = entry
        self.router = router
        self.dependencies = dependencies
        self.onFinish = onFinish
        self.onSplitBill = onSplitBill
        self.onViewSplit = onViewSplit
        _flowViewModel = State(
            initialValue: TransferFlowViewModel(
                walletRepository: dependencies.walletRepository,
                sessionStore: dependencies.sessionStore,
                transferRepository: dependencies.transferRepository
            )
        )
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            root
            .navigationDestination(for: TransferDestination.self) { destination in
                switch destination {
                case .confirm:
                    TransferConfirmView(
                        viewModel: flowViewModel,
                        onBack: { router.navigateBack() },
                        onConfirm: {
                            router.navigate(to: TransferDestination.otp)
                        },
                        onCancel: onFinish
                    )

                case .otp:
                    OTPVerificationView(
                        viewModel: flowViewModel,
                        onBack: { router.navigateBack() },
                        onSuccess: {
                            router.navigate(to: TransferDestination.success)
                        }
                    )

                case .success:
                    // Only reached right after submitOTP() sets the receipt.
                    if let receipt = flowViewModel.receipt {
                        TransferSuccessView(
                            receipt: receipt,
                            onViewDetails: {
                                router.navigate(
                                    to: TransferDestination.detail(
                                        transactionId: receipt.id,
                                        receiverName: receipt.receiverHolderName,
                                        isOutgoing: true
                                    )
                                )
                            },
                            onBackToHome: onFinish
                        )
                    }

                case .detail(let transactionId, let receiverName, let isOutgoing):
                    TransactionDetailView(
                        viewModel: TransactionDetailViewModel(
                            transactionId: transactionId,
                            receiverHolderName: receiverName,
                            isOutgoing: isOutgoing,
                            transferRepository: dependencies.transferRepository
                        ),
                        onBack: { router.navigateBack() },
                        onSplitBill: onSplitBill,
                        onViewSplit: onViewSplit,
                        onBackToHome: onFinish
                    )
                }
            }
        }
        // Tab bar only shows on this tab's entry screen, not on anything pushed on top.
        .toolbar(router.navPath.isEmpty ? .visible : .hidden, for: .tabBar)
        .environment(router)
    }
}

extension TransferCoordinator {
    @ViewBuilder
    fileprivate var root: some View {
        switch entry {
        case .flow:
            TransferInputView(
                viewModel: flowViewModel,
                onBack: onFinish,
                onContinue: {
                    router.navigate(to: TransferDestination.confirm)
                }
            )

        case .history:
            TransactionHistoryView(
                viewModel: TransactionHistoryViewModel(
                    transferRepository: dependencies.transferRepository
                ),
                onSelect: { item in
                    router.navigate(
                        to: TransferDestination.detail(
                            transactionId: item.id,
                            receiverName: item.counterpartyName
                                ?? item.counterpartyWalletNumber
                                ?? "Unknown",
                            isOutgoing: item.direction == .sent
                        )
                    )
                }
            )
        }
    }
}

extension TransferCoordinator {
    public struct Dependencies {
        let walletRepository: IWalletRepository
        let sessionStore: SessionStore
        let transferRepository: ITransferRepository

        public init(
            walletRepository: IWalletRepository,
            sessionStore: SessionStore,
            transferRepository: ITransferRepository
        ) {
            self.walletRepository = walletRepository
            self.sessionStore = sessionStore
            self.transferRepository = transferRepository
        }
    }
}
