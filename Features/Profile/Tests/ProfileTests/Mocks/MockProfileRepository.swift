//
//  MockProfileRepository.swift
//  ProfileTests
//

import Domains
import Foundation

final class MockProfileRepository: IProfileRepository, @unchecked Sendable {
    var profile: Profile?
    var error: Error?

    // Gates the profile call so a test can hold it mid-flight and probe
    // the view model's reentrancy guard.
    var holdGetCurrentProfile = false
    private var continuation: CheckedContinuation<Void, Never>?

    func resumeGetCurrentProfile() {
        continuation?.resume()
        continuation = nil
    }

    private(set) var getCurrentProfileCalls = 0
    private(set) var updateProfileCalls = 0
    private(set) var lastUpdatedFullName: String?
    private(set) var lastUpdatedPhoneNumber: String?

    func getCurrentProfile() async throws -> Profile {
        getCurrentProfileCalls += 1
        if holdGetCurrentProfile {
            await withCheckedContinuation { continuation = $0 }
        }
        if let error { throw error }
        guard let profile else { throw DomainError.notFound }
        return profile
    }

    func updateProfile(fullName: String?, phoneNumber: String?) async throws -> Profile {
        updateProfileCalls += 1
        lastUpdatedFullName = fullName
        lastUpdatedPhoneNumber = phoneNumber
        if let error { throw error }
        guard let profile else { throw DomainError.notFound }
        return profile
    }
}
