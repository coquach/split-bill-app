//
//  RestAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import DomainDatas
import Foundation
import Supabase
import Swinject

// Wires SupabaseRestClient and its access-token source for the migrated repositories.
final class RestAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AccessTokenProviding.self) { r in
            SupabaseAccessTokenProvider(
                client: r.resolve(SupabaseClient.self)!
            )
        }
        .inObjectScope(.container)

        container.register(SupabaseRestClient.self) { r in
            SupabaseRestClient(
                baseURL: Bundle.main.supabaseURL,
                apiKey: Bundle.main.supabaseKey,
                accessTokenProvider: r.resolve(AccessTokenProviding.self)!
            )
        }
        .inObjectScope(.container)
    }
}
