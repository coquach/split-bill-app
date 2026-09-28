//
//  AppCoordinate.swift
//  SplitPay
//
//  Created by Co Quach on 18/9/26.
//

import Domains
import Observation
import SwiftUI

enum AppRoot {
    case loading
    case unauthenticated
    case authenticated(Domains.User)
}

@Observable
@MainActor
final class AppCoordinator {

    var root: AppRoot = .loading

    let authRepository: IAuthRepository
    let walletRepository: IWalletRepository
    let sessionStore: SessionStore
    let transferRepository: ITransferRepository
    let splitBillRepository: ISplitBillRepository

    private var authTask: Task<Void, Never>?

    init(
        authRepository: IAuthRepository,
        walletRepository: IWalletRepository,
        sessionStore: SessionStore,
        transferRepository: ITransferRepository,
        splitBillRepository: ISplitBillRepository
    ) {
        self.authRepository = authRepository
        self.walletRepository = walletRepository
        self.sessionStore = sessionStore
        self.transferRepository = transferRepository
        self.splitBillRepository = splitBillRepository
    }

    func start() {
        guard authTask == nil else { return }

        authTask = Task { [weak self] in
            guard let self else {
                return
            }

            for await authStateChanges in authRepository.authStateChanges {
                switch authStateChanges {
                case .authenticated(let user):
                    root = .authenticated(user)
                    refreshBalance()

                case .unauthenticated:
                    root = .unauthenticated
                }
            }
        }
    }

    func validateSession() {
        Task { [weak self] in
            guard let self else {
                return
            }

            let isValid = await authRepository.validateSession()

            guard !Task.isCancelled else {
                return
            }

            guard !isValid else {
                return
            }

            root = .unauthenticated
        }
    }

    /// Loads the wallet balance into `SessionStore` once, on sign-in. Every
    /// other module reads the cached value rather than fetching its own —
    /// without this call it stays at zero, which silently disables Continue
    /// on the Transfer input screen (any amount "exceeds" a zero balance).
    ///
    /// Also called after the Transfer flow closes, since a completed
    /// transfer has just changed the real balance.
    func refreshBalance() {
        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                try await sessionStore.refreshBalance()
            } catch {
                // The cached balance is a UX affordance, not correctness —
                // the backend re-validates at submit time. A failure here
                // just means the input screen shows a stale number, so it
                // isn't worth interrupting the user over.
                print("[AppCoordinator] balance refresh failed: \(error)")
            }
        }
    }

    func stop() {
        authTask?.cancel()
        authTask = nil
    }
}
