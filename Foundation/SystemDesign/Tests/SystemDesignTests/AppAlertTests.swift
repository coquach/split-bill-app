//
//  AppAlertTests.swift
//  SystemDesignTests
//

@testable import SystemDesign
import Testing

@Suite("AppAlert")
struct AppAlertTests {
    @Test
    func twoAlertsBuiltAlikeAreStillDistinct() {
        // The id is minted per instance, so alerts never compare equal —
        // SwiftUI's .alert(item:) relies on that to re-present on change.
        let first = AppAlert(title: "Oops", message: "Something went wrong.")
        let second = AppAlert(title: "Oops", message: "Something went wrong.")

        #expect(first != second)
        #expect(first.id != second.id)
    }

    @Test
    func theTitleAndMessageSurviveTheInit() {
        let alert = AppAlert(title: "Payment complete", message: "200,000 VND sent.")

        #expect(alert.title == "Payment complete")
        #expect(alert.message == "200,000 VND sent.")
    }
}
