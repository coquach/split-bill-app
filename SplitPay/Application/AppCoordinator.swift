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

    private var authTask: Task<Void, Never>?

    init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    func start() {
        guard authTask == nil else { return }

        authTask = Task { [weak self] in
            guard let self else {
                return
            }

            for await authState in authRepository.authState {
                switch authState {
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
