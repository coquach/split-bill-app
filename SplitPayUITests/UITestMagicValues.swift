//
//  UITestMagicValues.swift
//  SplitPayUITests
//

/// Magic values the app-side mock repositories react to. Mirrored from
/// `UITestSeedData` in the app target (which isn't visible to this bundle) —
/// treat both sides as one contract: change them together.
enum UITestMagicValues {
    static let failingEmail = "fail@test.com"
    static let failingPin = "000000"
    static let recipientAccountNumber = "0123456789"
    static let recipientHolderName = "Trần Mai"
}
