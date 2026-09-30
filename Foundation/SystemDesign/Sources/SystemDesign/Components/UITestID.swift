//
//  UITestID.swift
//  SystemDesign
//
//  Central registry of accessibility identifiers used by XCUITest
//  (SplitPayUITests). Components take their identifier from here via the
//  call sites so the strings never drift between app and tests.
//

public enum UITestID {
    // MARK: - Auth

    public static let loginEmail = "login.email"
    public static let loginPassword = "login.password"
    public static let loginSubmit = "login.submit"
    public static let loginSignUpLink = "login.signUpLink"

    public static let registerFullName = "register.fullName"
    public static let registerPhone = "register.phone"
    public static let registerEmail = "register.email"
    public static let registerPassword = "register.password"
    public static let registerConfirmPassword = "register.confirmPassword"
    public static let registerSubmit = "register.submit"

    // MARK: - Tabs

    public static let tabHome = "tab.home"
    public static let tabHistory = "tab.history"
    public static let tabSplit = "tab.split"
    public static let tabProfile = "tab.profile"
    public static let scanQR = "home.scanQR"

    // MARK: - Home

    public static let homeBalance = "home.balance"
    public static let homeTransferAction = "home.transferAction"
    public static let homeSplitAction = "home.splitAction"
    public static let homeSeeAll = "home.seeAll"

    // MARK: - Transfer

    public static let transferReceiverField = "transfer.receiverField"
    public static let transferAmountField = "transfer.amountField"
    public static let transferNoteField = "transfer.noteField"
    public static let transferContinue = "transfer.continue"
    public static let transferConfirm = "transfer.confirm"
    public static let transferOtpInput = "transfer.otpInput"
    public static let transferSuccessDone = "transfer.success.done"
    public static let historyRowPrefix = "history.row"
    public static let detailSplitBill = "detail.splitBill"

    // MARK: - Split Bill

    public static let splitHistoryRowPrefix = "split.historyRow"
    public static let splitParticipantsMinus = "split.setup.participants.minus"
    public static let splitParticipantsPlus = "split.setup.participants.plus"
    public static let splitCreate = "split.setup.create"
    public static let splitQRSave = "split.qr.save"
    public static let scanClose = "scan.close"

    public static let repayReviewConfirm = "repay.review.confirm"
    public static let repayPinInput = "repay.pinInput"
    public static let repaySuccessDone = "repay.success.done"

    // MARK: - Profile

    public static let profilePinCard = "profile.pinCard"
    public static let profileLogout = "profile.logout"
    public static let profilePinField = "profile.pinField"
    public static let profilePinSubmit = "profile.pinSubmit"

    // MARK: - Errors

    public static let errorModalTitle = "error.modal.title"
    public static let errorModalRetry = "error.modal.retry"
}
