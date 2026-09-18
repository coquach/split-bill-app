//
//  Validation.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import Foundation

enum EmailValidator {

    private static let pattern =
        #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

    static func validate(_ email: String) -> Bool {
        let email = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !email.isEmpty else {
            return false
        }

        return email.range(
            of: pattern,
            options: [
                .regularExpression,
                .caseInsensitive
            ]
        ) != nil
    }
}

enum PasswordValidator {

    static let minimumLength = 8

    static func validate(_ password: String) -> Bool {
        password.count >= minimumLength
    }
}
