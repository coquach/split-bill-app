//
//  Profile.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct Profile: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let fullName: String?
    public let phoneNumber: String?
    public let email: String?
    public let biometricsEnabled: Bool
    public let status: UserStatus
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        fullName: String?,
        phoneNumber: String?,
        email: String?,
        biometricsEnabled: Bool,
        status: UserStatus,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.email = email
        self.biometricsEnabled = biometricsEnabled
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
