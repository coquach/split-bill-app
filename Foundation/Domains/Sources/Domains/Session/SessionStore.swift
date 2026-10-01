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

    /// `nil` means "we haven't got a balance", which is deliberately not the
    /// same thing as `Amount(0)`.
    ///
    /// Collapsing the two is how a failed fetch turns into a silent dead end:
    /// a zero balance makes every amount look like it overdraws the wallet,
    /// so the Transfer screen disables Continue and shows nothing to explain
    /// why. Keeping "unknown" distinct lets the UI say so, and lets the
    /// backend — which is the authority anyway — be the one to reject a
    /// transfer the wallet can't cover.
    public private(set) var availableBalance: Amount?

    private let walletRepository: IWalletRepository

    public init(
        walletRepository: IWalletRepository,
        availableBalance: Amount? = nil
    ) {
        self.walletRepository = walletRepository
        self.availableBalance = availableBalance
    }

    public func refreshBalance() async throws {
        let wallet = try await walletRepository.getDefaultWallet()
        availableBalance = Amount(Double(wallet.balance))
    }
}
