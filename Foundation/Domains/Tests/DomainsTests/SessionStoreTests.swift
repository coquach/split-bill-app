//
//  SessionStoreTests.swift
//  DomainsTests
//

import Domains
import Testing

@Suite("SessionStore")
@MainActor
struct SessionStoreTests {
    private let repository = MockWalletRepository()

    @Test
    func startsWithoutABalanceWhenNoneIsGiven() {
        let store = SessionStore(walletRepository: repository)
        #expect(store.availableBalance == nil)
    }

    @Test
    func aSeededZeroBalanceIsNotUnknown() {
        // The nil-vs-zero distinction is the whole point of this type:
        // zero is a real balance, nil means "never fetched".
        let store = SessionStore(walletRepository: repository, availableBalance: Amount(0))
        #expect(store.availableBalance == Amount(0))
    }

    @Test
    func refreshBalanceCachesTheWalletBalance() async throws {
        repository.wallet = makeWallet(balance: 250_000)
        let store = SessionStore(walletRepository: repository)

        try await store.refreshBalance()

        #expect(store.availableBalance == Amount(250_000))
        #expect(repository.getDefaultWalletCalls == 1)
    }

    @Test
    func refreshBalanceKeepsThePreviousValueWhenTheFetchThrows() async {
        repository.error = DomainError.network
        let store = SessionStore(walletRepository: repository)

        await #expect(throws: DomainError.self) {
            try await store.refreshBalance()
        }

        #expect(store.availableBalance == nil)
    }

    @Test
    func refreshBalancePreservesASeededBalanceOnFailure() async {
        repository.error = DomainError.network
        let store = SessionStore(walletRepository: repository, availableBalance: Amount(100))

        await #expect(throws: DomainError.self) {
            try await store.refreshBalance()
        }

        #expect(store.availableBalance == Amount(100))
    }
}
