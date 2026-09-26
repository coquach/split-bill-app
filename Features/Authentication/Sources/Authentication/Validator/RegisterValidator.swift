//
//  SignUpValidator.swift
//  Authentication
//
//  Created by Co Quach on 26/9/26.
//

struct RegisterValidationResult {
    let fullNameError: String?
    let phoneError: String?
    let emailError: String?
    let passwordError: String?
    let confirmPasswordError: String?

    var isValid: Bool {
        fullNameError == nil &&
        phoneError == nil &&
        emailError == nil &&
        passwordError == nil &&
        confirmPasswordError == nil
    }
}

enum RegisterValidator {

    static func validate(
        fullName: String,
        phone: String,
        email: String,
        password: String,
        confirmPassword: String
    ) -> RegisterValidationResult {
        
        let name = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        let phone = phone.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        let email = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        var fullNameError: String?
        var phoneError: String?
        var emailError: String?
        var passwordError: String?
        var confirmPasswordError: String?
        
        if name.isEmpty {
            fullNameError = "Full name is required."
        }
        
        if phone.isEmpty {
            phoneError = "Phone number is required."
        } else if !isValidPhone(phone) {
            phoneError = "Please enter a valid phone number."
        }
        
        if email.isEmpty {
            emailError = "Email is required."
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email address."
        }
        
        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters."
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password."
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
        }
        
        return RegisterValidationResult(
            fullNameError: fullNameError,
            phoneError: phoneError,
            emailError: emailError,
            passwordError: passwordError,
            confirmPasswordError: confirmPasswordError
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
    
    private static func isValidPhone(_ phone: String) -> Bool {
        let pattern = #"^\+?[0-9]{9,15}$"#
        
        return phone.range(
            of: pattern,
            options: .regularExpression
        ) != nil
    }
}
