//
//  SplitBillCreation.swift
//  Domains
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

/// What `create_split_bill` hands back: the split **and** its QR code.
///
/// The RPC generates both in one call — its result columns include a
/// `qr_*` block alongside the split's own fields. Modelling that here means
/// the Split QR screen doesn't need a second round trip to
/// `generate_split_qr` just to show the code we were already given.
///
/// `qrCode` is optional because the columns are nullable: if the backend
/// ever creates a split without a code, the Split QR screen needs to say so
/// rather than crash on a force-unwrap.
public struct SplitBillCreation: Sendable, Equatable {
    public let splitBill: SplitBill
    public let qrCode: SplitQRCode?

    public init(splitBill: SplitBill, qrCode: SplitQRCode?) {
        self.splitBill = splitBill
        self.qrCode = qrCode
    }
}
