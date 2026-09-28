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
    let transferRepository: ITransferRepository
    let profileRepository: IProfileRepository
    let pinRepository: IPinRepository
    let repaymentRepository: IRepaymentRepository
    let splitBillRepository: ISplitBillRepository
    let splitQRRepository: ISplitQRRepository

    private var authTask: Task<Void, Never>?

    init(
        authRepository: IAuthRepository,
        walletRepository: IWalletRepository,
        transferRepository: ITransferRepository,
        profileRepository: IProfileRepository,
        pinRepository: IPinRepository,
        repaymentRepository: IRepaymentRepository,
        splitBillRepository: ISplitBillRepository,
        splitQRRepository: ISplitQRRepository
        
    ) {
        self.authRepository = authRepository
        self.walletRepository = walletRepository
        self.transferRepository = transferRepository
        self.profileRepository = profileRepository
        self.pinRepository = pinRepository
        self.repaymentRepository = repaymentRepository
        self.splitBillRepository = splitBillRepository
        self.splitQRRepository = splitQRRepository
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

    func stop() {
        authTask?.cancel()
        authTask = nil
    }
}
