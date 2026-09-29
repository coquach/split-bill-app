//
//  SplitCalculator.swift
//  Domains
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

public enum SplitCalculator {

    public static let fractionDigits = 2

    private static let epsilon = 0.005

    public struct Result: Sendable, Equatable {
        public let perPersonAmount: Amount

        public let requesterAmount: Amount

        public let requiredSlots: Int

        public let splitsEvenly: Bool
    }
    
    public static func equalSplit(
        totalAmount: Amount,
        participantCount: Int
    ) -> Result {
        let people = max(participantCount, 2)

        let scale = pow(10.0, Double(fractionDigits))
        let rawShare = totalAmount.amount / Double(people)
        let perPerson = (rawShare * scale).rounded() / scale

        let requiredSlots = people - 1
        let requesterAmount =
            totalAmount.amount - perPerson * Double(requiredSlots)

        return Result(
            perPersonAmount: Amount(perPerson),
            requesterAmount: Amount(requesterAmount),
            requiredSlots: requiredSlots,

            splitsEvenly: abs(requesterAmount - perPerson) < epsilon
        )
    }
}
