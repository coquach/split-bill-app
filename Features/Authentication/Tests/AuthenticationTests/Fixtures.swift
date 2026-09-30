//
//  Fixtures.swift
//  AuthenticationTests
//

import Domains
import Foundation

func makeUser(email: String = "an.nguyen@example.com") -> User {
    User(id: UUID(), email: email)
}
