//
//  ProfileRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class ProfileRepository: IProfileRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func getCurrentProfile() async throws -> Profile {
        do {
            let user = try await client.auth.user()

            let dto: ProfileDTO =
                try await client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
                .value

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
            let user = try await client.auth.user()

            let values = ProfileUpdateDTO(
                fullName: fullName,
                phoneNumber: phoneNumber
            )

            let dto: ProfileDTO =
                try await client
                .from("profiles")
                .update(values)
                .eq("id", value: user.id.uuidString)
                .select()
                .single()
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
