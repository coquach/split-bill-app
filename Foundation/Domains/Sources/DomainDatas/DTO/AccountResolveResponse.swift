//
//  File.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Domains
import Foundation
import Network

// response: `GET /api/v1/accounts/{accountNumber}`.
struct AccountResolveResponse: Decodable {
    let accountNumber: String
    let holderName: String
}

struct AccountResolveResponseMapper: Mappable {
    func map(_ input: AccountResolveResponse) throws -> ResolvedAccount {
        ResolvedAccount(
            accountNumber: input.accountNumber,
            holderName: input.holderName
        )
    }
}
