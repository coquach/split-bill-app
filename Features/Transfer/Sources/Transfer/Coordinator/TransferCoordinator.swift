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
    case input
    case confirm(TransferDraft)
    case otp(TransferDraft)
    case success(TransferReceipt)
    case detail(transactionId: UUID, receiverName: String)
}

public struct TransferCoordinator: View {
    @State private var router = Router()
    private let entry: TransferEntry
    private let dependencies: Dependencies
    private let onFinish: () -> Void
    private let onSplitBill: (SplitSource) -> Void

    public init(
        entry: TransferEntry = .flow,
        dependencies: Dependencies,
        onFinish: @escaping () -> Void,
        onSplitBill: @escaping (SplitSource) -> Void
    ) {
        self.entry = entry
        self.dependencies = dependencies
        self.onFinish = onFinish
        self.onSplitBill = onSplitBill
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            root
            .navigationDestination(for: TransferDestination.self) { destination in
                switch destination {
                case .input:
                    TransferInputView(
                        viewModel: TransferInputViewModel(
                            walletRepository: dependencies.walletRepository,
                            sessionStore: dependencies.sessionStore
                        ),
                        onBack: { router.navigateBack() },
                        onContinue: { draft in
                            router.navigate(to: TransferDestination.confirm(draft))
                        }
                    )

                case .confirm(let draft):
                    TransferConfirmView(
                        viewModel: TransferConfirmViewModel(draft: draft),
                        onBack: { router.navigateBack() },
                        onConfirm: {
                            router.navigate(to: TransferDestination.otp(draft))
                        },
                        onCancel: onFinish
                    )

                case .otp(let draft):
                    OTPVerificationView(
                        viewModel: OTPVerificationViewModel(
                            draft: draft,
                            transferRepository: dependencies.transferRepository
                        ),
                        onBack: { router.navigateBack() },
                        onSuccess: { receipt in
                            router.navigate(to: TransferDestination.success(receipt))
                        }
                    )

                case .success(let receipt):
                    TransferSuccessView(
                        receipt: receipt,
                        onViewDetails: {
                            router.navigate(
                                to: TransferDestination.detail(
                                    transactionId: receipt.id,
                                    receiverName: receipt.receiverHolderName
                                )
                            )
                        },
                        onBackToHome: onFinish
                    )

                case .detail(let transactionId, let receiverName):
                    TransactionDetailView(
                        viewModel: TransactionDetailViewModel(
                            transactionId: transactionId,
                            receiverHolderName: receiverName,
                            transferRepository: dependencies.transferRepository
                        ),
                        onBack: { router.navigateBack() },
                        onSplitBill: onSplitBill,
                        onBackToHome: onFinish
                    )
                    // The detail screen pins its own bottom bar, which the tab
                    // bar would otherwise sit on top of.
                    .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .environment(router)
    }
}

extension TransferCoordinator {
    @ViewBuilder
    fileprivate var root: some View {
        switch entry {
        case .flow:
            TransferPinGateView(
                viewModel: PinGateViewModel(),
                onVerified: { router.navigate(to: TransferDestination.input) },
                onCancel: onFinish
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
                                ?? "Unknown"
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
