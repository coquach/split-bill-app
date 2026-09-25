//
//  File.swift
//  Network
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation


public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol EndPointType: Sendable {
    var baseURL: URL? { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var urlQueries: [String: String]? { get }
    var headers: [String: String]? { get }
    /// Already-JSON-encoded request body, or `nil` for a body-less request
    /// (like a plain `GET`).
    var body: Data? { get }
}

//  APIEndpoint(path: "/api/v1/accounts/\(accountNumber)", httpMethod: .get)
public struct APIEndpoint: EndPointType {
    public let baseURL: URL?
    public let path: String
    public let httpMethod: HTTPMethod
    public let urlQueries: [String: String]?
    public let headers: [String: String]?
    public let body: Data?

    public init(
        baseURL: URL? = nil,
        path: String,
        httpMethod: HTTPMethod,
        urlQueries: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.urlQueries = urlQueries
        self.headers = headers
        self.body = body
    }

    public init<T: Encodable>(
        baseURL: URL? = nil,
        path: String,
        httpMethod: HTTPMethod,
        urlQueries: [String: String]? = nil,
        headers: [String: String]? = nil,
        encodableBody: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.init(
            baseURL: baseURL,
            path: path,
            httpMethod: httpMethod,
            urlQueries: urlQueries,
            headers: headers,
            body: try encoder.encode(encodableBody)
        )
    }
}
