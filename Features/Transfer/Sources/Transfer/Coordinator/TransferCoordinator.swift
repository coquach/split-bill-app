//
//  TransferCoordinator.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Router
import SwiftUI

public enum TransferDestination: Hashable {
    case input
    case confirm(TransferDraft)
    case otp(TransferDraft)
    case success(TransferReceipt)
}

public struct TransferCoordinator: View {
    @State private var router = Router()
    private let dependencies: Dependencies
    private let onFinish: () -> Void

    public init(dependencies: Dependencies, onFinish: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onFinish = onFinish
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            TransferPinGateView(
                viewModel: PinGateViewModel(),
                onVerified: {
                    router.navigate(to: TransferDestination.input)
                },
                onCancel: onFinish
            )
            .navigationDestination(for: TransferDestination.self) { destination in
                switch destination {
                case .input:
                    TransferInputView(
                        viewModel: TransferInputViewModel(
                            accountRepository: dependencies.accountRepository,
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
                        // Transaction Detail isn't built yet (out of scope for
                        // this slice) - falls back to the same as Back to Home.
                        onViewDetails: onFinish,
                        onBackToHome: onFinish
                    )
                }
            }
        }
        .environment(router)
    }
}

extension TransferCoordinator {
    public struct Dependencies {
        let accountRepository: IAccountRepository
        let sessionStore: SessionStore
        let transferRepository: ITransferRepository

        public init(
            accountRepository: IAccountRepository,
            sessionStore: SessionStore,
            transferRepository: ITransferRepository
        ) {
            self.accountRepository = accountRepository
            self.sessionStore = sessionStore
            self.transferRepository = transferRepository
        }
    }
}
