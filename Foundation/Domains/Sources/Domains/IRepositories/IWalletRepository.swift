//
//  IWalletRepository.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

public protocol IWalletRepository: Sendable {
    func fetchBalance() async throws -> Amount
}
