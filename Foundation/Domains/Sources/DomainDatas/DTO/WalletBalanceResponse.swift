//
//  WalletBalanceResponse.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Network

// response: `GET /api/v1/wallet/balance`.
struct WalletBalanceResponse: Decodable {
    let balance: Double
}

struct WalletBalanceResponseMapper: Mappable {
    func map(_ input: WalletBalanceResponse) throws -> Amount {
        Amount(input.balance)
    }
}
