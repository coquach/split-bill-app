//
//  SupabaseAssembly.swift
//  SplitPay
//
//  Created by Co Quach on 18/9/26.
//

import Domains
import DomainDatas
import Foundation
import Supabase
import Swinject

// Wires the Supabase SDK client, the REST client used by the migrated
// repositories, and its access-token source.
final class SupabaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SupabaseClient.self) { _ in
            SupabaseClient(
                supabaseURL: Bundle.main.supabaseURL,
                supabaseKey: Bundle.main.supabaseKey
            )
        }
        .inObjectScope(.container)

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
