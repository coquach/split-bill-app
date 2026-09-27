//
//  WalletAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import DomainDatas
import Network
import Swinject

final class WalletAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IWalletRepository.self) { resolver in
            let apiClient = resolver.resolve(IAPIClientService.self)!
            return WalletRepository(apiClient: apiClient)
        }
        .inObjectScope(.container)
    }
}
