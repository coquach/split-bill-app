//
//  SupabaseAssembly.swift
//  SplitPay
//
//  Created by Co Quach on 18/9/26.
//

import Foundation
import Supabase
import Swinject

final class SupabaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SupabaseClient.self) { _ in
            SupabaseClient(
                supabaseURL: Bundle.main.supabaseURL,
                supabaseKey: Bundle.main.supabaseKey
            )
        }
        .inObjectScope(.container)
    }
}
