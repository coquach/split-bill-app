//
//  Account.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

struct ResolvedAccount: Equatable, Hashable, Codable {

    let accountNumber: String
    let holderName: String

    var displayAccountNumber: String {
        accountNumber
    }

    var initials: String {
        let firstLetters = holderName
            .split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0) }

        return firstLetters.isEmpty ? "?" : firstLetters.joined().uppercased()
    }
}
