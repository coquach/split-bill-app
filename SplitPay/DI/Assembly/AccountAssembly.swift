//
//  AccountAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 25/9/26.
//

import Domains
import DomainDatas
import Network
import Swinject

final class AccountAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IAccountRepository.self) { resolver in
            let apiClient = resolver.resolve(IAPIClientService.self)!
            return AccountRepository(apiClient: apiClient)
        }
        .inObjectScope(.container)
    }
}
