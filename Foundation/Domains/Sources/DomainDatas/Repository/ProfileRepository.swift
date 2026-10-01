//
//  ProfileRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

public final class ProfileRepository: IProfileRepository {
    private let client: SupabaseRestClient
    private let accessTokenProvider: AccessTokenProviding

    public init(
        client: SupabaseRestClient,
        accessTokenProvider: AccessTokenProviding
    ) {
        self.client = client
        self.accessTokenProvider = accessTokenProvider
    }

    public func getCurrentProfile() async throws -> Profile {
        do {
            let userId = try await accessTokenProvider.currentUserId()

            let dto: ProfileDTO = try await client.select(
                table: "profiles",
                filters: ["id": "eq.\(userId.uuidString)"],
                single: true
            )

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func updateProfile(
        fullName: String?,
        phoneNumber: String?
    ) async throws -> Profile {
        do {
            let userId = try await accessTokenProvider.currentUserId()

            let dto: ProfileDTO = try await client.update(
                table: "profiles",
                filters: ["id": "eq.\(userId.uuidString)"],
                body: ProfileUpdateDTO(
                    fullName: fullName,
                    phoneNumber: phoneNumber
                ),
                single: true
            )

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
