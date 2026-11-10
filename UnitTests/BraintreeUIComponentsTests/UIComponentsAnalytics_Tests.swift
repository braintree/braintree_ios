import XCTest
@testable import BraintreeUIComponents

final class UIComponentsAnalytics_Tests: XCTestCase {

    func test_cardFieldsAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(UIComponentsAnalytics.cardFieldsPresented, "ui-components:card-fields:presented")
        XCTAssertEqual(UIComponentsAnalytics.cardFieldsValidated, "ui-components:card-fields:validated")
    }

    func test_payPalButtonAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(UIComponentsAnalytics.payPalButtonPresented, "ui-components:paypal-button:presented")
        XCTAssertEqual(UIComponentsAnalytics.payPalButtonSelected, "ui-components:paypal-button:selected")
    }

    func test_venmoButtonAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(UIComponentsAnalytics.venmoButtonPresented, "ui-components:venmo-button:presented")
        XCTAssertEqual(UIComponentsAnalytics.venmoButtonSelected, "ui-components:venmo-button:selected")
    }

    func test_payLaterButtonAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(UIComponentsAnalytics.payLaterButtonPresented, "ui-components:pay-later-button:presented")
        XCTAssertEqual(UIComponentsAnalytics.payLaterButtonSelected, "ui-components:pay-later-button:selected")
    }
}
