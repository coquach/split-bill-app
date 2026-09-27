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
    public let pPin: String
    enum CodingKeys: String, CodingKey { case pPin = "p_pin" }
    public init(pin: String) { self.pPin = pin }
}

public struct SetupPinResponse: Decodable, Sendable, Equatable {
    public let success: Bool
    public let data: SetupPinData?
    public let error: String?
}
public struct SetupPinData: Decodable, Sendable, Equatable {
    public let hasPin: Bool
    enum CodingKeys: String, CodingKey { case hasPin = "has_pin" }
}

public struct ChangePinRequest: Encodable, Sendable {
    public let oldPin: String
    public let newPin: String
    enum CodingKeys: String, CodingKey {
        case oldPin = "p_old_pin"
        case newPin = "p_new_pin"
    }
    public init(oldPin: String, newPin: String) {
        self.oldPin = oldPin
        self.newPin = newPin
    }
}

public struct VerifyPinRequest: Encodable, Sendable {
    public let pin: String
    enum CodingKeys: String, CodingKey { case pin = "p_pin" }
    public init(pin: String) { self.pin = pin }
}

public struct VerifyPinResponse: Decodable, Sendable, Equatable {
    public let valid: Bool
    public let remainingAttempts: Int?
    public let lockedUntil: Date?
    enum CodingKeys: String, CodingKey {
        case valid
        case remainingAttempts = "remaining_attempts"
        case lockedUntil = "locked_until"
    }
}

public struct PinStatusResponse: Decodable, Sendable, Equatable {
    public let hasPin: Bool
    enum CodingKeys: String, CodingKey { case hasPin = "has_pin" }
}
