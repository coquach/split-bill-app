//
//  APIEndpointTests.swift
//  NetworkTests
//

import Foundation
import Network
import Testing

@Suite("HTTPMethod")
struct HTTPMethodTests {
    @Test(arguments: [
        (HTTPMethod.get, "GET"),
        (.post, "POST"),
        (.put, "PUT"),
        (.patch, "PATCH"),
        (.delete, "DELETE")
    ])
    func rawValuesMatchTheWire(method: HTTPMethod, raw: String) {
        #expect(method.rawValue == raw)
    }
}

@Suite("APIEndpoint")
struct APIEndpointTests {
    private struct Payload: Codable, Equatable {
        let amount: Int
    }

    @Test
    func defaultInitLeavesTheOptionalFieldsNil() {
        let endpoint = APIEndpoint(
            path: "/api/v1/accounts",
            httpMethod: .get
        )

        #expect(endpoint.baseURL == nil)
        #expect(endpoint.urlQueries == nil)
        #expect(endpoint.headers == nil)
        #expect(endpoint.body == nil)
        #expect(endpoint.path == "/api/v1/accounts")
        #expect(endpoint.httpMethod == .get)
    }

    @Test
    func storesABaseURLAndQueries() throws {
        let url = try #require(URL(string: "https://api.example.com"))
        let endpoint = APIEndpoint(
            baseURL: url,
            path: "/api/v1/wallets",
            httpMethod: .get,
            urlQueries: ["status": "eq.ACTIVE"],
            headers: ["X-Request-Id": "abc"]
        )

        #expect(endpoint.baseURL == url)
        #expect(endpoint.urlQueries?["status"] == "eq.ACTIVE")
        #expect(endpoint.headers?["X-Request-Id"] == "abc")
    }

    @Test
    func encodableBodyInitEncodesThePayloadAsJson() throws {
        let endpoint = try APIEndpoint(
            path: "/api/v1/transfers",
            httpMethod: .post,
            encodableBody: Payload(amount: 500)
        )

        let decoded = try JSONDecoder().decode(Payload.self, from: #require(endpoint.body))
        #expect(decoded == Payload(amount: 500))
    }

    @Test
    func encodableBodyInitKeepsTheOtherFields() throws {
        let endpoint = try APIEndpoint(
            path: "/api/v1/transfers",
            httpMethod: .post,
            headers: ["Idempotency-Key": "key-1"],
            encodableBody: Payload(amount: 1)
        )

        #expect(endpoint.httpMethod == .post)
        #expect(endpoint.headers?["Idempotency-Key"] == "key-1")
    }
}
