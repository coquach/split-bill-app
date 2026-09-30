//
//  UITestConfig.swift
//  SplitPay
//
//  Launch-argument/environment configuration for XCUITest runs. When the
//  app is launched with `-UITest` the DI container swaps the Supabase
//  assemblies for in-memory mock repositories (see `MockAppAssembly`), so
//  UI tests exercise the real navigation and views against deterministic
//  data instead of a backend.
//

#if DEBUG
    import Foundation

    nonisolated enum UITestScenario: String {
        case none
        /// `getTransfers` throws — exercises the history error banner + retry.
        case historyFails = "history-fails"
        /// Transfer OTP submit and repay PIN verification fail — exercises the
        /// error modals on both money-movement flows.
        case otpFails = "otp-fails"
        /// `decodeQR` throws — exercises the scan-flow error modal.
        case qrDecodeFails = "qr-decode-fails"
        /// `validateSession` returns false — drops the app back to Login on the
        /// next scene activation.
        case sessionInvalid = "session-invalid"
    }

    /// Which canned dataset the mock repositories serve.
    nonisolated enum UITestDataSet: String {
        /// No transfers, no split bills — empty states everywhere.
        case empty
        /// A realistic mix used by most suites.
        case `default`
    }

    nonisolated enum UITestConfig {
        static let launchArgument = "-UITest"

        static var isEnabled: Bool {
            ProcessInfo.processInfo.arguments.contains(launchArgument)
        }

        static var isAuthenticated: Bool {
            ProcessInfo.processInfo.environment["UITEST_AUTHENTICATED"] != "0"
        }

        static var dataSet: UITestDataSet {
            UITestDataSet(
                rawValue: ProcessInfo.processInfo.environment["UITEST_DATA"] ?? ""
            ) ?? .default
        }

        static var scenario: UITestScenario {
            UITestScenario(
                rawValue: ProcessInfo.processInfo.environment["UITEST_SCENARIO"] ?? ""
            ) ?? .none
        }
    }
#endif
