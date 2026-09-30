//
//  LoginValidatorTests.swift
//  AuthenticationTests
//

import Foundation
import Testing

@testable import Authentication

@Suite("LoginValidator")
struct LoginValidatorTests {

    @Test
    func anEmptyEmailIsRejected() {
        let result = LoginValidator.validate(email: "", password: "secret123")
        #expect(result.emailError == "Email is required.")
        #expect(!result.isValid)
    }

    @Test
    func aWhitespaceOnlyEmailIsRejected() {
        let result = LoginValidator.validate(email: "   ", password: "secret123")
        #expect(result.emailError == "Email is required.")
    }

    @Test(arguments: [
        "not-an-email", "missing-at.com", "missing-tld@", "@no-local-part.com",
    ])
    func aMalformedEmailIsRejected(email: String) {
        let result = LoginValidator.validate(email: email, password: "secret123")
        #expect(result.emailError == "Please enter a valid email address.")
        #expect(!result.isValid)
    }

    @Test
    func anEmptyPasswordIsRejected() {
        let result = LoginValidator.validate(email: "an@example.com", password: "")
        #expect(result.passwordError == "Password is required.")
        #expect(!result.isValid)
    }

    @Test
    func surroundingWhitespaceIsTrimmedBeforeValidation() {
        let result = LoginValidator.validate(email: "  an@example.com  ", password: "secret123")
        #expect(result.emailError == nil)
        #expect(result.isValid)
    }

    @Test
    func aValidPairPassesWithNoErrors() {
        let result = LoginValidator.validate(email: "an@example.com", password: "secret123")
        #expect(result.emailError == nil)
        #expect(result.passwordError == nil)
        #expect(result.isValid)
    }
}
