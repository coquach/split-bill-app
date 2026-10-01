//
//  MockWalletRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockWalletRepository: IWalletRepository, @unchecked Sendable {
        private let store: MockAppStore

        private(set) var resolveCalls = 0

        init(store: MockAppStore) {
            self.store = store
        }

        func getDefaultWallet() async throws -> Wallet {
            store.wallet
        }

        func getWallets() async throws -> [Wallet] {
            [store.wallet]
        }

        func resolveWallet(walletNumber: String) async throws -> WalletRecipient {
            resolveCalls += 1
            guard walletNumber != UITestSeedData.unknownAccountNumber else {
                throw DomainError.notFound
            }
            return WalletRecipient(
                walletId: UUID(),
                walletNumber: walletNumber,
                holderName: UITestSeedData.recipientHolderName
            )
        }
    }
#endif
