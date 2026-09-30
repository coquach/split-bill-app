//
//  UITestCase.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// Base class for the mock-backend UI suites. Subclass this (not XCTestCase)
/// to get the launch-argument seam, app reference and wait helpers.
///
/// The app is launched once per test with `-UITest`, which swaps the DI
/// container for in-memory mock repositories — a fresh mock store per test
/// process, so tests never need to reset state. Not launching through this
/// helper hits the real Supabase assembly and the network.
class UITestCase: XCTestCase {
    let app = XCUIApplication()

    /// Standard mock timeout: the app boots through the launch screen (fast
    /// path when -UITest is set) and any screen transition under the mocks is
    /// instantaneous; the slack is for simulator warm-up on CI.
    static let timeout: TimeInterval = 10

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    /// Launches the app against the mock backend. All arguments have the
    /// defaults most suites want: authenticated user, the rich-ish default
    /// dataset, no injected failure.
    func launch(
        authenticated: Bool = true,
        data: String = "default",
        scenario: String = ""
    ) {
        app.launchArguments += ["-UITest"]
        app.launchEnvironment["UITEST_AUTHENTICATED"] = authenticated ? "1" : "0"
        app.launchEnvironment["UITEST_DATA"] = data
        app.launchEnvironment["UITEST_SCENARIO"] = scenario
        app.launch()
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    @discardableResult
    func wait(_ identifier: String, timeout: TimeInterval = UITestCase.timeout) -> XCUIElement {
        let found = element(identifier)
        XCTAssertTrue(
            found.waitForExistence(timeout: timeout),
            "Element '\(identifier)' never appeared"
        )
        return found
    }

    /// Waits for an element to exist, then taps it.
    func tap(_ identifier: String, timeout: TimeInterval = UITestCase.timeout) {
        wait(identifier, timeout: timeout).tap()
    }

    /// Tab-bar buttons expose their label, not always the identifier set on
    /// the Label inside `.tabItem { }` — try the identifier first, fall back
    /// to the visible label.
    func tapTab(identifier: String, label: String, timeout: TimeInterval = 10) {
        let byIdentifier = app.tabBars.buttons.matching(identifier: identifier).firstMatch
        if byIdentifier.waitForExistence(timeout: 2) {
            byIdentifier.tap()
            return
        }
        let byLabel = app.tabBars.buttons[label]
        XCTAssertTrue(
            byLabel.waitForExistence(timeout: timeout),
            "Tab '\(label)' never appeared"
        )
        byLabel.tap()
    }

    /// Types into a text field: taps to focus first, then types. Used for
    /// the transparent TextField inside OTPCodeInput too — the visible boxes
    /// are decorations; only the hidden field accepts text.
    func type(_ identifier: String, _ text: String) {
        let field = wait(identifier)
        if !field.isHittable {
            // Off-screen inside a ScrollView — bring it into view first,
            // otherwise the synthesized tap lands wherever the element would be.
            app.swipeUp()
        }
        field.tap()
        typeUntilComplete(field, text)
    }

    /// Types and verifies the field actually received the full text. Fields
    /// with password autofill (`.textContentType(.password)`) can have their
    /// keystrokes swallowed by the strong-password suggestion, leaving a
    /// partial value — retype, then fall back to pasting from the clipboard.
    private func typeUntilComplete(_ field: XCUIElement, _ text: String) {
        for attempt in 0 ..< 3 {
            field.typeText(text)

            let value = field.value as? String ?? ""
            if value.count >= text.count {
                return
            }

            // Clear what made it in, then try another route.
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
            if attempt == 2 {
                pasteInto(field, text)
                let final = field.value as? String ?? ""
                if final.count < text.count {
                    XCTFail("Could not fill field with '\(text)' — kept receiving '\(final)'")
                }
            }
        }
    }

    /// Long-press → Paste. The XCUITest runner shares the simulator's
    /// pasteboard, so setting it from the test process works.
    private func pasteInto(_ field: XCUIElement, _ text: String) {
        UIPasteboard.general.string = text
        field.press(forDuration: 1.5)

        let paste = app.menuItems["Paste"]
        if paste.waitForExistence(timeout: 2) {
            paste.tap()
        }
    }

    /// The AppModal error overlay is a plain ZStack overlay, not a system
    /// alert — query it by its title identifier, never via app.alerts.
    @discardableResult
    func waitErrorModal(timeout: TimeInterval = UITestCase.timeout) -> XCUIElement {
        wait(UITestID.errorModalTitle, timeout: timeout)
    }
}
