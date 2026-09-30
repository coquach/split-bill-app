import Swinject

final class AppContainer: @unchecked Sendable {
    private let container: Container

    init() {
        container = Container()
        #if DEBUG
        if UITestConfig.isEnabled {
            Assembler([MockAppAssembly()], container: container)
            return
        }
        #endif
        Assembler(
            [
                SupabaseAssembly(),
                RestAssembly(),
                DomainDataAssembly(),
                SessionAssembly(),
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
