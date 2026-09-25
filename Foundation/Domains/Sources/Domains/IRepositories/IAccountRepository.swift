//
//  File.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation

public protocol IAccountRepository: Sendable {
    func resolveAccount(accountNumber: String) async throws -> ResolvedAccount
}
