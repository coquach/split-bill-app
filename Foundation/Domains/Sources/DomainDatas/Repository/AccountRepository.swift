//
//  File.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Domains
import Foundation
import Network

enum APIEndpoints {
    static func resolveAccount(accountNumber: String) -> APIEndpoint {
        APIEndpoint(
            path: "/api/v1/accounts/\(accountNumber)",
            httpMethod: .get
        )
    }
}

public final class AccountRepository: IAccountRepository {
    private let apiClient: IAPIClientService

    public init(apiClient: IAPIClientService) {
        self.apiClient = apiClient
    }

    public func resolveAccount(accountNumber: String) async throws -> ResolvedAccount {
        do {
            let endpoint = APIEndpoints.resolveAccount(accountNumber: accountNumber)
            let response = try await apiClient.request(endpoint, for: AccountResolveResponse.self)
            return try AccountResolveResponseMapper().map(response)
        } catch let error as APIError {
            throw Self.map(error)
        }
    }

    private static func map(_ error: APIError) -> AccountRepositoryError {
        switch error {
        case .serverError(let code, _):
            return code == "ACCOUNT_NOT_FOUND" ? .notFound : .unknown
        case .networkError:
            return .network
        case .invalidEndpoint, .badServerResponse, .decodingError:
            return .unknown
        }
    }
}
