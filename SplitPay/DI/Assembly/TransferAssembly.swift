//
//  TransferAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import DomainDatas
import Network
import Swinject

final class TransferAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ITransferRepository.self) { resolver in
            let apiClient = resolver.resolve(IAPIClientService.self)!
            return TransferRepository(apiClient: apiClient)
        }
        .inObjectScope(.container)
    }
}
