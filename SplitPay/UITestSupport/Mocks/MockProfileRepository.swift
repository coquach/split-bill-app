//
//  MockProfileRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockProfileRepository: IProfileRepository {
        private let store: MockAppStore

        init(store: MockAppStore) {
            self.store = store
        }

        func getCurrentProfile() async throws -> Profile {
            store.profile
        }

        func updateProfile(fullName _: String?, phoneNumber _: String?) async throws -> Profile {
            store.profile
        }
    }
#endif
