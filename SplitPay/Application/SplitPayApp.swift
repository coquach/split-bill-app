import Authentication
import Domains
import Home
import SwiftUI
import Transfer

@main
struct SplitPayApp: App {
    private let container: AppContainer
    private let coordinator: AppCoordinator

    init() {
        let container = AppContainer()

        self.container = container
        self.coordinator = AppCoordinator(
            authRepository: container.resolve(IAuthRepository.self),
            accountRepository: container.resolve(IAccountRepository.self),
            sessionStore: container.resolve(SessionStore.self),
            transferRepository: container.resolve(ITransferRepository.self)
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
    @State private var isTransferPresented = false

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
            HomeView(
                viewModel: HomeViewModel(
                    user: user,
                    authRepository: coordinator.authRepository,
                    sessionStore: coordinator.sessionStore
                ),
                onTransferTapped: { isTransferPresented = true }
            )
            .fullScreenCover(isPresented: $isTransferPresented) {
                TransferCoordinator(
                    dependencies: .init(
                        accountRepository: coordinator.accountRepository,
                        sessionStore: coordinator.sessionStore,
                        transferRepository: coordinator.transferRepository
                    ),
                    onFinish: { isTransferPresented = false }
                )
            }
        }
    }
}
