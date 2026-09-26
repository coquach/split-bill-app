//
//  TransferRequest.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

// request body: `POST /api/v1/transfers`.
struct TransferRequest: Encodable {
    let receiverAccountNumber: String
    let amount: Double
    let description: String
    let pin: String
}
