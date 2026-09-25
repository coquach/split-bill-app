//
//  APIClientService.swift
//  Network
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation

public enum APIError: Error, Sendable {
    case invalidEndpoint
    // Server not responded with 2xx
    case badServerResponse(statusCode: Int)
    // Request never reached the server (no internet, timeout)
    case networkError(String)
    // Unexpected response type
    case decodingError(String)
    // Server's own error - "ACCOUNT_NOT_FOUND"
    case serverError(code: String, message: String)
}

struct ServerMessage<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIErrorPayload?
}

struct APIErrorPayload: Decodable {
    let code: String
    let message: String
}

public protocol IAPIClientService: Sendable {
    func request<T: Decodable>(
        _ endpoint: EndPointType,
        for type: T.Type,
        decoder: JSONDecoder
    ) async throws -> T
}

extension IAPIClientService {
    public func request<T: Decodable>(
        _ endpoint: EndPointType,
        for type: T.Type
    ) async throws -> T {
        try await request(endpoint, for: type, decoder: JSONDecoder())
    }
}

public final class APIClientService: IAPIClientService, Sendable {
    
    public struct Configuration: Sendable {
        public let baseURL: URL?
        public let headers: [String: String]

        public init(baseURL: URL?, headers: [String: String] = [:]) {
            self.baseURL = baseURL
            self.headers = headers
        }
    }

    private let session: URLSession
    private let configuration: Configuration

    public init(session: URLSession = .shared, configuration: Configuration) {
        self.session = session
        self.configuration = configuration
    }

    public func request<T: Decodable>(
        _ endpoint: EndPointType,
        for type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let urlRequest = try buildURLRequest(from: endpoint)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest) // the actual network call
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            // Even on a failing status, the envelope may still carry a real error code
            if let serverMessage = try? decoder.decode(ServerMessage<T>.self, from: data),
               let serverError = serverMessage.error {
                throw APIError.serverError(code: serverError.code, message: serverError.message)
            }
            throw APIError.badServerResponse(statusCode: statusCode)
        }

        let serverMessage: ServerMessage<T>
        do {
            serverMessage = try decoder.decode(ServerMessage<T>.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }

        if let serverError = serverMessage.error {
            throw APIError.serverError(code: serverError.code, message: serverError.message)
        }
        guard let payload = serverMessage.data else {
            throw APIError.decodingError("Response envelope had no data")
        }
        return payload // Caller gets just the payload, never the envelope itself
    }

    // Turns an EndPointType value into a real URLRequest.
    private func buildURLRequest(from endpoint: EndPointType) throws -> URLRequest {
        guard let baseURL = endpoint.baseURL ?? configuration.baseURL else {
            throw APIError.invalidEndpoint
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = endpoint.path // e.g. "/api/v1/accounts/123"
        if let queries = endpoint.urlQueries {
            components?.queryItems = queries.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else {
            throw APIError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.httpBody = endpoint.body
        request.allHTTPHeaderFields = configuration.headers.merging(
            endpoint.headers ?? [:]
        ) { _, endpointValue in endpointValue } // endpoint-specific headers win over shared defaults

        return request
    }
}
