//
//  SplitCalculatorTests.swift
//  DomainsTests
//

import Domains
import Testing

@Suite("SplitCalculator.equalSplit")
struct SplitCalculatorTests {
    struct Case: Sendable {
        let total: Double
        let participants: Int
        let perPerson: Double
        let requester: Double
        let requiredSlots: Int
        let splitsEvenly: Bool
    }

    private static let cases: [Case] = [
        // Even split: everyone pays the same, no extra slot.
        Case(total: 100, participants: 2, perPerson: 50, requester: 50, requiredSlots: 1, splitsEvenly: true),
        // 0 and 1 participant both clamp up to 2 people.
        Case(total: 100, participants: 0, perPerson: 50, requester: 50, requiredSlots: 1, splitsEvenly: true),
        Case(total: 100, participants: 1, perPerson: 50, requester: 50, requiredSlots: 1, splitsEvenly: true),
        // 100 / 3 = 33.33 per person; the requester absorbs the rounding
        // remainder so the parts still add back up to the total.
        Case(total: 100, participants: 3, perPerson: 33.33, requester: 33.34, requiredSlots: 2, splitsEvenly: false),
        Case(total: 40, participants: 3, perPerson: 13.33, requester: 13.34, requiredSlots: 2, splitsEvenly: false),
        // 100 / 6 = 16.666… must round UP to 16.67 — pins that shares use
        // nearest-value rounding, not floor.
        Case(total: 100, participants: 6, perPerson: 16.67, requester: 16.65, requiredSlots: 5, splitsEvenly: false),
        // Many participants: 9 slots of 10, requester takes the last share.
        Case(total: 100, participants: 10, perPerson: 10, requester: 10, requiredSlots: 9, splitsEvenly: true),
        // Negative amounts are not special-cased — mirrored arithmetic.
        Case(total: -10, participants: 2, perPerson: -5, requester: -5, requiredSlots: 1, splitsEvenly: true),
        // Just inside the 0.005 epsilon: 100.004 / 2 = 50.002 rounds to
        // 50.00, leaving a 0.004 gap — still considered "even".
        Case(total: 100.004, participants: 2, perPerson: 50, requester: 50.004, requiredSlots: 1, splitsEvenly: true),
        // Just outside it: 100.02 / 2 = 50.01, requester 50.01 — even again.
        Case(total: 100.02, participants: 2, perPerson: 50.01, requester: 50.01, requiredSlots: 1, splitsEvenly: true)
    ]

    @Test(arguments: cases)
    func splitsTheBill(case: Case) {
        let result = SplitCalculator.equalSplit(
            totalAmount: Amount(`case`.total),
            participantCount: `case`.participants
        )

        #expect(abs(result.perPersonAmount.amount - `case`.perPerson) < 0.000_001)
        #expect(abs(result.requesterAmount.amount - `case`.requester) < 0.000_001)
        #expect(result.requiredSlots == `case`.requiredSlots)
        #expect(result.splitsEvenly == `case`.splitsEvenly)
    }

    @Test
    func partsAlwaysAddBackUpToTheTotal() {
        // Odd totals for every participant count from 2 to 25: the per-person
        // shares plus the requester's share must reconstruct the total.
        for participants in 2 ... 25 {
            let total = Double(participants) * 10.0 + 0.03
            let result = SplitCalculator.equalSplit(
                totalAmount: Amount(total),
                participantCount: participants
            )

            let sum = result.perPersonAmount.amount * Double(result.requiredSlots)
                + result.requesterAmount.amount
            #expect(
                abs(sum - total) < 0.000_001,
                "participants: \(participants), sum: \(sum), total: \(total)"
            )
        }
    }

    @Test
    func fractionDigitsIsTwo() {
        #expect(SplitCalculator.fractionDigits == 2)
    }

    @Test
    func resultIsEquatable() {
        let first = SplitCalculator.equalSplit(totalAmount: Amount(100), participantCount: 2)
        let second = SplitCalculator.equalSplit(totalAmount: Amount(100), participantCount: 2)
        #expect(first == second)
        #expect(first != SplitCalculator.equalSplit(totalAmount: Amount(100), participantCount: 3))
    }
}
