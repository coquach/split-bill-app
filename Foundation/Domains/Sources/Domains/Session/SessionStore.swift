//
//  SessionStore.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Observation

/// Shared app-level session state. Fetched once (login/Home) and cached
/// here — other modules read `availableBalance`, they don't re-fetch it
/// themselves. This cached value is for UX only: the backend re-validates
/// the real balance at submit time, so never trust this number for
/// correctness, only for things like disabling a button early.
@MainActor
@Observable
public final class SessionStore {
    public private(set) var availableBalance: Amount

    private let walletRepository: IWalletRepository

    public init(
        walletRepository: IWalletRepository,
        availableBalance: Amount = Amount(0)
    ) {
        self.walletRepository = walletRepository
        self.availableBalance = availableBalance
    }

    public func refreshBalance() async throws {
        availableBalance = try await walletRepository.fetchBalance()
    }
}
