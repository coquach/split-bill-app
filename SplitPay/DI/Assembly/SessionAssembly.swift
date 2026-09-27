//
//  SessionAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Swinject

final class SessionAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SessionStore.self) { resolver in
            let walletRepository = resolver.resolve(IWalletRepository.self)!
            return SessionStore(walletRepository: walletRepository)
        }
        .inObjectScope(.container)
    }
}
