//
//  User.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct User: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let email: String

    public init(
        id: UUID,
        email: String
    ) {
        self.id = id
        self.email = email
    }
}
