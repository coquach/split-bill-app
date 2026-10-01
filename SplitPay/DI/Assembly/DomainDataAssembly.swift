//
//  DomainDataAssembly.swift
//  SplitPay
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import DomainDatas
import Supabase
import Swinject

final class DomainDataAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IAuthRepository.self) { r in AuthRepository(client: r.resolve(SupabaseClient.self)!) }.inObjectScope(.container)
        container.register(IPinRepository.self) { r in PinRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(IProfileRepository.self) { r in
            ProfileRepository(
                client: r.resolve(SupabaseRestClient.self)!,
                accessTokenProvider: r.resolve(AccessTokenProviding.self)!
            )
        }.inObjectScope(.container)
        container.register(IWalletRepository.self) { r in WalletRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(ITransferRepository.self) { r in TransferRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(ISplitBillRepository.self) { r in SplitBillRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(ISplitQRRepository.self) { r in SplitQRRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(IRepaymentRepository.self) { r in RepaymentRepository(client: r.resolve(SupabaseRestClient.self)!) }.inObjectScope(.container)
        container.register(SessionStore.self) { r in
            SessionStore(walletRepository: r.resolve(IWalletRepository.self)!)
        }.inObjectScope(.container)
    }
}
