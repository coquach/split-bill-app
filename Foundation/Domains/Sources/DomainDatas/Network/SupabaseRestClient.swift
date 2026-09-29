//
//  SupabaseRestClient.swift
//  DomainDatas
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Foundation

// PostgREST's error body: {message, code, details, hint} - not ServerMessage<T>.
public struct RestErrorBody: Decodable, Sendable, Error {
    public let message: String
    public let code: String?
    public let details: String?
    public let hint: String?
}

// Talks to Supabase's PostgREST API (/rest/v1/...) over HTTPS directly, replacing .from()/.rpc().
public final class SupabaseRestClient: Sendable {
    private let baseURL: URL
    private let apiKey: String
    private let accessTokenProvider: AccessTokenProviding
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        apiKey: String,
        accessTokenProvider: AccessTokenProviding,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.accessTokenProvider = accessTokenProvider
        self.session = session
        self.encoder = Self.makeEncoder()
        self.decoder = Self.makeDecoder()
    }

    // POST /rest/v1/rpc/<function>
    public func rpc<Params: Encodable, Response: Decodable>(
        _ function: String,
        params: Params
    ) async throws -> Response {
        var request = try await makeRequest(
            path: "rest/v1/rpc/\(function)",
            method: "POST"
        )
        request.httpBody = try encoder.encode(params)
        return try await execute(request)
    }

    // GET /rest/v1/<table>?<filters>; filter values carry their operator, e.g. "status": "eq.ACTIVE".
    public func select<Response: Decodable>(
        table: String,
        filters: [String: String] = [:],
        order: String? = nil,
        single: Bool = false
    ) async throws -> Response {
        var query = filters.map { URLQueryItem(name: $0.key, value: $0.value) }
        if let order {
            query.append(URLQueryItem(name: "order", value: order))
        }

        var request = try await makeRequest(
            path: "rest/v1/\(table)",
            method: "GET",
            query: query
        )

        if single {
            // Mirrors .single(): errors on 0 or >1 rows, returns one object not an array.
            request.setValue(
                "application/vnd.pgrst.object+json",
                forHTTPHeaderField: "Accept"
            )
        }

        return try await execute(request)
    }

    // MARK: - Request building

    private func makeRequest(
        path: String,
        method: String,
        query: [URLQueryItem] = []
    ) async throws -> URLRequest {
        guard
            var components = URLComponents(
                url: baseURL.appendingPathComponent(path),
                resolvingAgainstBaseURL: false
            )
        else {
            throw DomainError.unknown(
                code: nil,
                message: "Invalid REST URL for \(path)"
            )
        }

        if !query.isEmpty {
            components.queryItems = query
        }

        guard let url = components.url else {
            throw DomainError.unknown(
                code: nil,
                message: "Invalid REST URL for \(path)"
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // auth.uid() resolves from this token, not from apikey; falls back to the anon key.
        let accessToken = try await accessTokenProvider.currentAccessToken()
        request.setValue(
            "Bearer \(accessToken ?? apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

    private func execute<Response: Decodable>(
        _ request: URLRequest
    ) async throws -> Response {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DomainError.network
        }

        guard let http = response as? HTTPURLResponse else {
            throw DomainError.unknown(code: nil, message: "No HTTP response")
        }

        guard (200..<300).contains(http.statusCode) else {
            if let body = try? decoder.decode(RestErrorBody.self, from: data) {
                throw body
            }
            throw DomainError.unknown(
                code: "\(http.statusCode)",
                message: String(data: data, encoding: .utf8)
                    ?? "HTTP \(http.statusCode)"
            )
        }

        return try decoder.decode(Response.self, from: data)
    }

    // MARK: - Codable configuration

    // Matches Postgres timestamptz: ISO 8601, with or without fractional seconds.
    private static func makeDecoder() -> JSONDecoder {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFractional = ISO8601DateFormatter()
        withoutFractional.formatOptions = [.withInternetDateTime]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = withFractional.date(from: string)
                ?? withoutFractional.date(from: string)
            {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(string)"
            )
        }
        return decoder
    }

    private static func makeEncoder() -> JSONEncoder {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        return encoder
    }
}
