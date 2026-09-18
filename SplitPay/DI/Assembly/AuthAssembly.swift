import Domains
import DomainDatas
import Supabase
import Swinject

final class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IAuthRepository.self) { resolver in
            let client = resolver.resolve(SupabaseClient.self)!
            return AuthRepository(client: client)
        }
        .inObjectScope(.container)
    }
}
