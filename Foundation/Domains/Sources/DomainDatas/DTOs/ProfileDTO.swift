//
//  ProfileDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

struct ProfileDTO: Decodable, Sendable {
    let id: UUID
    let fullName: String?
    let phoneNumber: String?
    let email: String?
    let biometricsEnabled: Bool
    let status: UserStatus
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case email
        case biometricsEnabled = "biometrics_enabled"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toDomain() -> Profile {
        Profile(
            id: id,
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            biometricsEnabled: biometricsEnabled,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

public struct ProfileUpdateDTO: Encodable, Sendable {
    let fullName: String?
    let phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case phoneNumber = "phone_number"
    }
}
