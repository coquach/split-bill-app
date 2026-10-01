//
//  AccessTokenProviding.swift
//  Domains
//
//  Created by Dinh Long on 29/9/26.
//

import Foundation

// auth.uid() in every RPC resolves from this token, not from the API key.
public protocol AccessTokenProviding: Sendable {
    // nil when signed out - caller falls back to the anon key.
    func currentAccessToken() async throws -> String?
    // Throws if signed out - callers that need this have no sensible fallback.
    func currentUserId() async throws -> UUID
}
