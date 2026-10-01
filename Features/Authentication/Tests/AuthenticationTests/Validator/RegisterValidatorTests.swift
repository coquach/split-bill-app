//
//  RegisterValidatorTests.swift
//  AuthenticationTests
//

import Foundation
import Testing

@testable import Authentication

@Suite("RegisterValidator")
struct RegisterValidatorTests {

    private func validate(
        fullName: String = "An Nguyen",
        phone: String = "0912345678",
        email: String = "an@example.com",
        password: String = "secret123",
        confirmPassword: String = "secret123"
    ) -> RegisterValidationResult {
        RegisterValidator.validate(
            fullName: fullName,
            phone: phone,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }

    @Test
    func aCompleteValidFormPassesWithNoErrors() {
        let result = validate()
        #expect(result.isValid)
        #expect(result.fullNameError == nil)
        #expect(result.phoneError == nil)
        #expect(result.emailError == nil)
        #expect(result.passwordError == nil)
        #expect(result.confirmPasswordError == nil)
    }

    @Test
    func anEmptyNameIsRejected() {
        #expect(validate(fullName: "").fullNameError == "Full name is required.")
        // Whitespace-only counts as empty too.
        #expect(validate(fullName: "   ").fullNameError == "Full name is required.")
    }

    @Test
    func anEmptyPhoneIsRejected() {
        #expect(validate(phone: "").phoneError == "Phone number is required.")
    }

    @Test(arguments: [
        ("123456789", true),     // minimum 9 digits
        ("0912345678", true),    // 10 digits
        ("+84912345678", true),  // optional leading +
        ("12345678", false),     // too short
        ("1234567890123456", false), // too long
        ("091abc678", false),    // letters
        ("091 234 678", false),  // internal spaces
    ])
    func phoneValidityFollowsThePattern(phone: String, isValid: Bool) {
        let result = validate(phone: phone)
        #expect(
            (result.phoneError == nil) == isValid,
            "phone: \(phone), error: \(result.phoneError ?? "nil")"
        )
    }

    @Test
    func anEmptyEmailIsRejected() {
        #expect(validate(email: "").emailError == "Email is required.")
    }

    @Test
    func aMalformedEmailIsRejected() {
        #expect(validate(email: "not-an-email").emailError == "Please enter a valid email address.")
    }

    @Test
    func anEmptyPasswordIsRejected() {
        #expect(validate(password: "").passwordError == "Password is required.")
    }

    @Test
    func aShortPasswordIsRejected() {
        #expect(validate(password: "secret").passwordError == "Password must be at least 8 characters.")
    }

    @Test
    func anUnconfirmedPasswordIsRejected() {
        #expect(validate(confirmPassword: "").confirmPasswordError == "Please confirm your password.")
    }

    @Test
    func aMismatchedConfirmationIsRejected() {
        #expect(validate(confirmPassword: "different").confirmPasswordError == "Passwords do not match.")
    }

    @Test
    func whitespaceIsTrimmedFromNamePhoneAndEmail() {
        let result = validate(
            fullName: "  An Nguyen  ",
            phone: " 0912345678 ",
            email: " an@example.com "
        )
        #expect(result.isValid)
    }
}
