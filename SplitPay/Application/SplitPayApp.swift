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
            walletRepository: container.resolve(IWalletRepository.self),
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
    @Environment(\.scenePhase) private var scenePhase
    @State private var isTransferPresented = false

    var body: some View {
        Group {
            switch coordinator.root {
            case .loading:
                ProgressView()
                    .task { coordinator.start() }

            case .unauthenticated:
                AuthCoordinator(
                    dependencies: .init(
                        authRepository: coordinator.authRepository
                    )
                )

            case .authenticated(let user):
                HomeView(
                    viewModel: HomeViewModel(
                        user: user,
                        authRepository: coordinator.authRepository
                    )
                )
                // Temp test entry point, lives here (app target) rather than
                // inside HomeView so it doesn't depend on Home's own UI.
                .overlay(alignment: .bottomTrailing) {
                    Button("Test Transfer") { isTransferPresented = true }
                        .padding()
                }
                .fullScreenCover(
                    isPresented: $isTransferPresented,
                    // A completed transfer has moved money, so the cached
                    // balance is stale the moment this flow closes.
                    onDismiss: { coordinator.refreshBalance() }
                ) {
                    TransferCoordinator(
                        dependencies: .init(
                            walletRepository: coordinator.walletRepository,
                            sessionStore: coordinator.sessionStore,
                            transferRepository: coordinator.transferRepository
                        ),
                        onFinish: { isTransferPresented = false }
                    )
                }
            }
        }.onAppear {
            coordinator.start()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            coordinator.validateSession()
        }
    }
}
