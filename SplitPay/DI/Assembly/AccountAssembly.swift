//
//  AccountAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 25/9/26.
//

import Domains
import DomainDatas
import Supabase
import Swinject

final class AccountAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IAccountRepository.self) { resolver in
            let client = resolver.resolve(SupabaseClient.self)!
            return AccountRepository(client: client)
        }
        .inObjectScope(.container)
    }
}
