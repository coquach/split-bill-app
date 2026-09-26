//
//  NetworkAssembly.swift
//  SplitPay
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation
import Network
import Swinject

final class NetworkAssembly: Assembly {
    func assemble(container: Container) {
        container.register(IAPIClientService.self) { _ in
            APIClientService(
                configuration: .init(baseURL: Bundle.main.apiBaseURL)
            )
        }
        .inObjectScope(.container)
    }
}
