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
    case auth
    case home(user: User)
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

        authTask = Task {
            for await state in authRepository.authStateChanges {
                switch state {
                case .authenticated(let user):
                    root = .home(user: user)

                case .unauthenticated:
                    root = .auth
                }
            }
        }
    }
}
