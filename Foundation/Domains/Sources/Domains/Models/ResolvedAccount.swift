//
//  File.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation

public struct ResolvedAccount: Sendable, Equatable, Hashable {
    public let accountNumber: String

    public let holderName: String

    public init(accountNumber: String, holderName: String) {
        self.accountNumber = accountNumber
        self.holderName = holderName
    }
}
