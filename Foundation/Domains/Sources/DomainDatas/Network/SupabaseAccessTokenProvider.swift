//
//  SupabaseAccessTokenProvider.swift
//  DomainDatas
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Supabase

// Bridges SupabaseRestClient to the session the Supabase Auth SDK already manages.
public final class SupabaseAccessTokenProvider: AccessTokenProviding {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func currentAccessToken() async throws -> String? {
        try? await client.auth.session.accessToken
    }
}
