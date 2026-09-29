//
//  ScannedRepayment.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Foundation

// SplitQRReview is only the decoded preview; create_qr_repayment needs the
// original QR string back, so both travel together on the nav path.
public struct ScannedRepayment: Sendable, Equatable, Hashable {
    public let payload: String
    public let review: SplitQRReview

    public init(payload: String, review: SplitQRReview) {
        self.payload = payload
        self.review = review
    }
}

extension SplitQRReview: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(splitBillId)
    }
}
