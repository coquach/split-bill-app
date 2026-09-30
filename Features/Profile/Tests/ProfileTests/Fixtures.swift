//
//  Fixtures.swift
//  ProfileTests
//

import Domains
import Foundation

func makeProfile(
    fullName: String? = "Binh Tran",
    email: String? = "binh@example.com",
    phoneNumber: String? = "0912345678",
    status: UserStatus = .active
) -> Profile {
    Profile(
        id: UUID(),
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        biometricsEnabled: false,
        status: status,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}
