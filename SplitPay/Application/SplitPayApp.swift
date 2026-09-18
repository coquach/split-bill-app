import Authentication
import Domains
import SwiftUI

@main
struct SplitPayApp: App {
    private let container: AppContainer
        private let coordinator: AppCoordinator

        init() {
            let container = AppContainer()

            self.container = container
            self.coordinator = AppCoordinator(
                authRepository: container.resolve(IAuthRepository.self)
            )
        }

        var body: some Scene {
            WindowGroup {
                AppRootView()
                    .environment(coordinator)
            }
        }
}

private struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        switch coordinator.root {
        case .loading:
            ProgressView()
                .task { coordinator.start() }

        case .auth:
            AuthCoordinator(
                dependencies: .init(authRepository: coordinator.authRepository)
            )

        case .home(let user):
            Text("Home — \(user.email)")
        }
    }
}
