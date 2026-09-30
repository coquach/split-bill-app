//
//  MockAppAssembly.swift
//  SplitPay
//
//  Registers the same service set as the production assemblies, but backed
//  by in-memory mock repositories driven by `UITestSeedData`.
//

#if DEBUG
    import Domains
    import Swinject

    final class MockAppAssembly: Assembly {
        func assemble(container: Container) {
            let store = MockAppStore(seed: UITestSeedData.load(UITestConfig.dataSet))

            container.register(MockAppStore.self) { _ in store }
                .inObjectScope(.container)

            container.register(IAuthRepository.self) { _ in
                MockAuthRepository(
                    store: store,
                    authenticated: UITestConfig.isAuthenticated,
                    sessionIsValid: UITestConfig.scenario != .sessionInvalid
                )
            }
            .inObjectScope(.container)

            container.register(IWalletRepository.self) { _ in
                MockWalletRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(ITransferRepository.self) { _ in
                MockTransferRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(IProfileRepository.self) { _ in
                MockProfileRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(IPinRepository.self) { _ in
                MockPinRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(ISplitBillRepository.self) { _ in
                MockSplitBillRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(ISplitQRRepository.self) { _ in
                MockSplitQRRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(IRepaymentRepository.self) { _ in
                MockRepaymentRepository(store: store)
            }
            .inObjectScope(.container)

            container.register(SessionStore.self) { resolver in
                SessionStore(walletRepository: resolver.resolve(IWalletRepository.self)!)
            }
            .inObjectScope(.container)
        }
    }
#endif
