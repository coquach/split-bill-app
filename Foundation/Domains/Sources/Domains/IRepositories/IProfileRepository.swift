//
//  IProfileRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol IProfileRepository: Sendable {
    func getCurrentProfile() async throws -> Profile
    func updateProfile(fullName: String?, phoneNumber: String?) async throws -> Profile
}
