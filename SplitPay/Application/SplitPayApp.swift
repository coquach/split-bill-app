import Authentication
import Domains
import Home
import SplitBill
import SwiftUI
import SystemDesign
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
            transferRepository: container.resolve(ITransferRepository.self),
            splitBillRepository: container.resolve(ISplitBillRepository.self),
            splitQRRepository: container.resolve(ISplitQRRepository.self),
            repaymentRepository: container.resolve(IRepaymentRepository.self)
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

    /// Non-nil while the Split sub-flow is open. It lives here, not inside
    /// TransferCoordinator, because AppCoordinator's layer is the only place
    /// that's allowed to know about two feature modules at once.
    @State private var splitSource: SplitSource?

    /// Home's "Split" entry point — the list of splits this user created.
    @State private var isSplitHistoryPresented = false

    private var splitDependencies: SplitBillCoordinator.Dependencies {
        .init(
            splitBillRepository: coordinator.splitBillRepository,
            splitQRRepository: coordinator.splitQRRepository,
            repaymentRepository: coordinator.repaymentRepository
        )
    }

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
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Button("Test Transfer") { isTransferPresented = true }
                        Button("Test Split") { isSplitHistoryPresented = true }
                    }
                    .padding()
                }
                .fullScreenCover(isPresented: $isSplitHistoryPresented) {
                    SplitBillCoordinator(
                        entry: .history,
                        dependencies: splitDependencies,
                        onFinish: { isSplitHistoryPresented = false }
                    )
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
                        onFinish: { isTransferPresented = false },
                        onSplitBill: { source in splitSource = source }
                    )
                    // Presented from inside the Transfer cover so that
                    // closing Split returns to Transaction Detail rather than
                    // dropping the user all the way back to Home.
                    .fullScreenCover(item: $splitSource) { source in
                        SplitBillCoordinator(
                            entry: .create(source),
                            dependencies: splitDependencies,
                            onFinish: { splitSource = nil }
                        )
                    }
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
