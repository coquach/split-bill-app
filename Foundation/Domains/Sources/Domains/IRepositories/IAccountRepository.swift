//
//  File.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation

public enum AccountRepositoryError: Error, Sendable, Equatable {
    case notFound
    case network
    case unknown
}

public protocol IAccountRepository: Sendable {
    func resolveAccount(accountNumber: String) async throws -> ResolvedAccount
}
