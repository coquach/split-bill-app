//
//  WalletAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import DomainDatas
import Supabase
import Swinject

final class WalletAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IWalletRepository.self) { resolver in
            let client = resolver.resolve(SupabaseClient.self)!
            return WalletRepository(client: client)
        }
        .inObjectScope(.container)
    }
}
