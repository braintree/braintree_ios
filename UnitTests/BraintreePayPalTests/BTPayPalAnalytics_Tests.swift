import XCTest
@testable import BraintreePayPal

final class BTPayPalAnalytics_Tests: XCTestCase {
    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTPayPalAnalytics.tokenizeStarted, "paypal:tokenize:started")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeFailed, "paypal:tokenize:failed")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeSucceeded, "paypal:tokenize:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserLoginCanceled, "paypal:tokenize:browser-login:canceled")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationSucceeded, "paypal:tokenize:browser-presentation:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationFailed, "paypal:tokenize:browser-presentation:failed")
        XCTAssertEqual(BTPayPalAnalytics.browserLoginAlertCanceled, "paypal:tokenize:browser-login:alert-canceled")
        XCTAssertEqual(BTPayPalAnalytics.handleReturnStarted, "paypal:tokenize:handle-return:started")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchStarted, "paypal:tokenize:app-switch:started")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchSucceeded, "paypal:tokenize:app-switch:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchFailed, "paypal:tokenize:app-switch:failed")

        // MARK: Edit FI Events

        XCTAssertEqual(BTPayPalAnalytics.editFIStarted, "paypal:edit:started")
        XCTAssertEqual(BTPayPalAnalytics.editFIFailed, "paypal:edit:failed")
        XCTAssertEqual(BTPayPalAnalytics.editFISucceeded, "paypal:edit:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.editFIBrowserLoginCanceled, "paypal:edit:browser-login:canceled")
        XCTAssertEqual(BTPayPalAnalytics.editFIBrowserPresentationSucceeded, "paypal:edit:browser-presentation:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.editFIBrowserPresentationFailed, "paypal:edit:browser-presentation:failed")
        XCTAssertEqual(BTPayPalAnalytics.editFIBrowserLoginAlertCanceled, "paypal:edit:browser-login:alert-canceled")
    }
}
