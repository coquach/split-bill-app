//
//  PinRepository.swift
//  DomainDatas
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

/// All four PIN RPCs return a bare `boolean`, so each of these decodes a
/// scalar rather than a wrapper object. Failures (wrong PIN, PIN not set,
/// lockout) come back as raised Postgres errors, not as `false`, and
/// `RepositoryErrorMapper` turns those into the matching `DomainError`.
public final class PinRepository: IPinRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func checkPinStatus() async throws -> Bool {
        do {
            return try await client
                .rpc("check_pin_status")
                .execute()
                .value
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func setupPin(_ pin: String) async throws -> Bool {
        do {
            return try await client
                .rpc("setup_pin", params: SetupPinRequest(pin: pin))
                .execute()
                .value
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func changePin(
        currentPin: String,
        newPin: String
    ) async throws -> Bool {
        do {
            return try await client
                .rpc(
                    "change_pin",
                    params: ChangePinRequest(
                        currentPin: currentPin,
                        newPin: newPin
                    )
                )
                .execute()
                .value
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func verifyPin(_ pin: String) async throws -> Bool {
        do {
            return try await client
                .rpc("verify_pin", params: VerifyPinRequest(pin: pin))
                .execute()
                .value
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
