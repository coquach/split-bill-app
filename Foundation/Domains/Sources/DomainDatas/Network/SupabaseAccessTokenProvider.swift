//
//  SupabaseAccessTokenProvider.swift
//  DomainDatas
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Foundation
import Supabase

// Bridges SupabaseRestClient to the session the Supabase Auth SDK already manages.
public final class SupabaseAccessTokenProvider: AccessTokenProviding {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    // No try? — a failed session refresh must surface as an error (mapped to
    // .unauthorized by RepositoryErrorMapper), not as a request silently sent
    // without an Authorization header that comes back as a generic 401.
    public func currentAccessToken() async throws -> String? {
        try await client.auth.session.accessToken
    }

    public func currentUserId() async throws -> UUID {
        try await client.auth.user().id
    }
}
