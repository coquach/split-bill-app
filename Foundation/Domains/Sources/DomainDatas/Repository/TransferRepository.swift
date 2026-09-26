//
//  TransferRepository.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Network

extension APIEndpoints {
    static func submitTransfer(_ request: TransferRequest) throws -> APIEndpoint {
        try APIEndpoint(
            path: "/api/v1/transfers",
            httpMethod: .post,
            encodableBody: request
        )
    }
}

public final class TransferRepository: ITransferRepository {
    private let apiClient: IAPIClientService

    public init(apiClient: IAPIClientService) {
        self.apiClient = apiClient
    }

    public func submitTransfer(_ draft: TransferDraft, pin: String) async throws -> TransferReceipt {
        let request = TransferRequest(
            receiverAccountNumber: draft.receiverAccountNumber,
            amount: draft.amount.amount,
            description: draft.description,
            pin: pin
        )

        do {
            let endpoint = try APIEndpoints.submitTransfer(request)
            let response = try await apiClient.request(
                endpoint,
                for: TransferReceiptResponse.self,
                decoder: Self.receiptDecoder
            )
            return try TransferReceiptResponseMapper().map(response)
        } catch let error as APIError {
            throw Self.map(error)
        }
    }

    // The receipt's `createdAt` comes back as an ISO8601 string, unlike
    // the other endpoints in this module which have no dates to decode.
    private static let receiptDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static func map(_ error: APIError) -> TransferRepositoryError {
        switch error {
        case .serverError(let code, _):
            switch code {
            case "ACCOUNT_NOT_FOUND":
                return .accountNotFound
            case "INSUFFICIENT_BALANCE":
                return .insufficientBalance
            case "INVALID_AMOUNT":
                return .invalidAmount
            case "INVALID_PIN":
                return .invalidPin
            default:
                return .transferFailed
            }
        case .networkError:
            return .network
        case .invalidEndpoint, .badServerResponse, .decodingError:
            return .unknown
        }
    }
}
