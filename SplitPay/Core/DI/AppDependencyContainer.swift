//
//  AppDependencyContainer.swift
//  SplitPay
//
//  Created by Dinh Long on 15/9/26.
//

import Foundation
import Swinject

final class AppDependencyContainer {

    static let shared = AppDependencyContainer()

    private let container = Container()

    let sessionStore: SessionStore

    private init() {
        Self.registerServices(in: container)

        sessionStore = container.resolve(SessionStore.self)!
    }

    private static func registerServices(in container: Container) {
        container.register(AccountResolving.self) { _ in
            MockAccountResolvingService()
        }.inObjectScope(.container)

        container.register(WalletBalanceProviding.self) { _ in
            MockWalletBalanceProvidingService()
        }.inObjectScope(.container)

        container.register(SessionStore.self) { resolver in
            SessionStore(balanceProvider: resolver.resolve(WalletBalanceProviding.self)!)
        }.inObjectScope(.container)
    }
    
    func makeTransferDependency() -> TransferDependency {
        TransferDependency(
            accountResolver: container.resolve(AccountResolving.self)!,
            sessionStore: sessionStore
        )
    }
}
