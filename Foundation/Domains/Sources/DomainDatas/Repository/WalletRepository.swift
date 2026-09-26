//
//  WalletRepository.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Network

extension APIEndpoints {
    static func walletBalance() -> APIEndpoint {
        APIEndpoint(
            path: "/api/v1/wallet/balance",
            httpMethod: .get
        )
    }
}

public final class WalletRepository: IWalletRepository {
    private let apiClient: IAPIClientService

    public init(apiClient: IAPIClientService) {
        self.apiClient = apiClient
    }

    public func fetchBalance() async throws -> Amount {
        let endpoint = APIEndpoints.walletBalance()
        let response = try await apiClient.request(endpoint, for: WalletBalanceResponse.self)
        return try WalletBalanceResponseMapper().map(response)
    }
}
