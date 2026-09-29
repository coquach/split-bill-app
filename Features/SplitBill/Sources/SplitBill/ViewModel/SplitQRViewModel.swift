//
//  SplitQRViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation
import Observation
import SystemDesign
import UIKit

@MainActor
@Observable
public final class SplitQRViewModel {

    public let context: SplitQRContext

    public private(set) var saveMessage: String?

    public init(context: SplitQRContext) {
        self.context = context
    }

    public var subtitle: String {
        let noun = context.participantCount == 1 ? "person" : "people"
        return "\(context.counterpartyName) · \(context.participantCount) \(noun)"
    }

    public var perPersonText: String {
        let value = context.perPersonAmount.formatted(
            maximumFractionDigits: SplitCalculator.fractionDigits
        )
        return "\(value) VND"
    }

    public var qrImage: UIImage? {
        QRCard.renderedImage(for: context.qrPayload)
    }

    public func dismissSaveMessage() {
        saveMessage = nil
    }
}
