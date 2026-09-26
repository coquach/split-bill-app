//
//  TransferReceiptResponse.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Network

// response: `201 Created` body of `POST /api/v1/transfers`.
struct TransferReceiptResponse: Decodable {
    let id: String
    let receiverAccountNumber: String
    let receiverHolderName: String
    let amount: Double
    let description: String
    let createdAt: Date
    let status: String
}

struct TransferReceiptResponseMapper: Mappable {
    func map(_ input: TransferReceiptResponse) throws -> TransferReceipt {
        TransferReceipt(
            id: input.id,
            receiverAccountNumber: input.receiverAccountNumber,
            receiverHolderName: input.receiverHolderName,
            amount: Amount(input.amount),
            description: input.description,
            createdAt: input.createdAt,
            status: input.status
        )
    }
}
