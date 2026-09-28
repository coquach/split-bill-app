//
//  PinGateViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 27/9/26.
//

import Observation

@MainActor
@Observable
public final class PinGateViewModel {
    public var pin: String = ""
    public private(set) var isIncorrect = false

    public init() {}

    public var isPinComplete: Bool {
        pin.count == TransferPIN.length
    }

    public func verify() -> Bool {
        guard pin == TransferPIN.testValue else {
            isIncorrect = true
            pin = ""
            return false
        }
        isIncorrect = false
        return true
    }
}
