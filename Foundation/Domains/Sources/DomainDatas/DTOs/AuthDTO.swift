//
//  AuthDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct SignUpRequest: Encodable, Sendable {
    public let email: String
    public let password: String
    public let fullName: String
    public let phoneNumber: String

    public init(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String
    ) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
}

public struct SetupPinRequest: Encodable, Sendable {
    public let pin: String
    enum CodingKeys: String, CodingKey { case pin = "p_pin" }
    public init(pin: String) { self.pin = pin }
}

/// The RPC parameter is `p_current_pin`, not `p_old_pin` — sending the wrong
/// name makes Postgres reject the call as "function does not exist".
public struct ChangePinRequest: Encodable, Sendable {
    public let currentPin: String
    public let newPin: String
    enum CodingKeys: String, CodingKey {
        case currentPin = "p_current_pin"
        case newPin = "p_new_pin"
    }
    public init(currentPin: String, newPin: String) {
        self.currentPin = currentPin
        self.newPin = newPin
    }
}

public struct VerifyPinRequest: Encodable, Sendable {
    public let pin: String
    enum CodingKeys: String, CodingKey { case pin = "p_pin" }
    public init(pin: String) { self.pin = pin }
}
