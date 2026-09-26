//
//  AuthError.swift
//  Domains
//
//  Created by Co Quach on 26/9/26.
//

import Foundation

public enum AuthError: Error, Equatable {

    case invalidCredentials
    case emailAlreadyRegistered
    case emailNotConfirmed
    case invalidEmail
    case weakPassword

    case rateLimited
    case signUpDisabled

    case network
    case sessionExpired
    case unknown

    public var message: String {
        switch self {

        case .invalidCredentials:
            return "Invalid email or password."

        case .emailAlreadyRegistered:
            return "An account with this email already exists."

        case .emailNotConfirmed:
            return "Please confirm your email before signing in."

        case .invalidEmail:
            return "Please enter a valid email address."

        case .weakPassword:
            return "Password must be at least 8 characters."

        case .rateLimited:
            return "Too many attempts. Please try again later."

        case .signUpDisabled:
            return "Sign up is currently unavailable."

        case .network:
            return "Unable to connect. Please check your connection and try again."

        case .sessionExpired:
            return "Your session has expired. Please sign in again."

        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
