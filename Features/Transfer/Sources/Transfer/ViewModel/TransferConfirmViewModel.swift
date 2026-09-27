//
//  TransferConfirmViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Observation

@MainActor
@Observable
public final class TransferConfirmViewModel {
    public let draft: TransferDraft

    public init(draft: TransferDraft) {
        self.draft = draft
    }

    public var maskedAccountNumber: String {
        "•••• \(draft.receiverAccountNumber.suffix(4))"
    }
}
