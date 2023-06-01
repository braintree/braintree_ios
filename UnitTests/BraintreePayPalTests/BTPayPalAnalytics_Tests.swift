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
    }
}
