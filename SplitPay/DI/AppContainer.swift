import Swinject

final class AppContainer: @unchecked Sendable {
    private let container: Container

    init() {
        container = Container()
        Assembler(
            [
                SupabaseAssembly(),
                NetworkAssembly(),
                AuthAssembly(),
                AccountAssembly()
            ],
            container: container
        )
    }

    func resolve<T>(_ serviceType: T.Type) -> T {
        guard let service = container.resolve(serviceType) else {
            fatalError("Dependency not registered: \(serviceType)")
        }
        return service
    }
}
