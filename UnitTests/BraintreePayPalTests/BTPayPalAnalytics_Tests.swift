import XCTest
@testable import BraintreePayPal

final class BTPayPalAnalytics_Tests: XCTestCase {
    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTPayPalAnalytics.tokenizeStarted, "paypal:tokenize:started")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeFailed, "paypal:tokenize:failed")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeSucceeded, "paypal:tokenize:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserLoginCanceled, "paypal:tokenize:browser-login:canceled")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationStarted, "paypal:tokenize:browser-presentation:started")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationSucceeded, "paypal:tokenize:browser-presentation:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationFailed, "paypal:tokenize:browser-presentation:failed")
        XCTAssertEqual(BTPayPalAnalytics.browserLoginAlertCanceled, "paypal:tokenize:browser-login:alert-canceled")
        XCTAssertEqual(BTPayPalAnalytics.handleReturnStarted, "paypal:tokenize:handle-return:started")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchStarted, "paypal:tokenize:app-switch:started")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchSucceeded, "paypal:tokenize:app-switch:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.appSwitchFailed, "paypal:tokenize:app-switch:failed")
        XCTAssertEqual(BTPayPalAnalytics.defaultBrowserStarted, "paypal:tokenize:default-browser-switch:started")
        XCTAssertEqual(BTPayPalAnalytics.defaultBrowserSucceeded, "paypal:tokenize:default-browser-switch:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.defaultBrowserFailed, "paypal:tokenize:default-browser-switch:failed")
    }
}
