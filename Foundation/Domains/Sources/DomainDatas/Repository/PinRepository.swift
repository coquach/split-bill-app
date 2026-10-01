//
//  PinRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

public final class PinRepository: IPinRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func checkPinStatus() async throws -> Bool {
        do {
            return try await client.rpc(
                "check_pin_status",
                params: [String: String]()
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func setupPin(_ pin: String) async throws -> Bool {
        do {
            return try await client.rpc(
                "setup_pin",
                params: ["p_pin": pin]
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func changePin(
        oldPin: String,
        newPin: String
    ) async throws -> Bool {
        do {
            return try await client.rpc(
                "change_pin",
                params: [
                    "p_current_pin": oldPin,
                    "p_new_pin": newPin,
                ]
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func verifyPin(_ pin: String) async throws -> Bool {
        do {
            return try await client.rpc(
                "verify_pin",
                params: ["p_pin": pin]
            )
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
