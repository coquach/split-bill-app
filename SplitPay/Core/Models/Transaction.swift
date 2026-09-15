//
//  Transaction.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

struct Transaction: Equatable, Hashable, Codable {

    let id: String

    let receiver: ResolvedAccount

    let amount: Amount

    let description: String

    let createdAt: Date
}
