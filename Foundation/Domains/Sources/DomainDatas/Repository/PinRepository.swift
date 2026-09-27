//
//  PinRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class PinRepository: IPinRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func checkPinStatus() async throws -> Bool {
        do {
            let response: PinStatusResponse =
                try await client
                .rpc("check_pin_status")
                .execute()
                .value
            return response.hasPin
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func setupPin(_ pin: String) async throws {
        do {
            let response: SetupPinResponse =
                try await client
                .rpc(
                    "setup_pin",
                    params: SetupPinRequest(pin: pin)
                )
                .execute()
                .value

            if !response.success {
                throw DomainError.unknown(
                    code: response.error,
                    message: response.error ?? "Unable to set up PIN."
                )
            }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func changePin(
        oldPin: String,
        newPin: String
    ) async throws {
        do {
            _ =
                try await client
                .rpc(
                    "change_pin",
                    params: ChangePinRequest(
                        oldPin: oldPin,
                        newPin: newPin
                    )
                )
                .execute()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func verifyPin(
        _ pin: String
    ) async throws -> PinVerificationResult {
        do {
            let response: VerifyPinResponse =
                try await client
                .rpc(
                    "verify_pin",
                    params: VerifyPinRequest(pin: pin)
                )
                .execute()
                .value

            return PinVerificationResult(
                valid: response.valid,
                remainingAttempts: response.remainingAttempts,
                lockedUntil: response.lockedUntil
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
