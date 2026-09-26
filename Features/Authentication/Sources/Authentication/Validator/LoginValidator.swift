//
//  SignInValidator.swift
//  Authentication
//
//  Created by Co Quach on 26/9/26.
//

import Foundation

struct LoginValidationResult {
    let emailError: String?
    let passwordError: String?

    var isValid: Bool {
        emailError == nil &&
        passwordError == nil
    }
}

enum LoginValidator {

    static func validate(
        email: String,
        password: String
    ) -> LoginValidationResult {

        let email = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        var emailError: String?
        var passwordError: String?

        if email.isEmpty {
            emailError = "Email is required."
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email address."
        }

        if password.isEmpty {
            passwordError = "Password is required."
        }

        return LoginValidationResult(
            emailError: emailError,
            passwordError: passwordError
        )
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let pattern =
            #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        return email.range(
            of: pattern,
            options: [
                .regularExpression,
                .caseInsensitive
            ]
        ) != nil
    }
}
