import XCTest
@testable import BraintreePayPal

final class BTPayPalAnalytics_Tests: XCTestCase {
    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTPayPalAnalytics.vaultRequestStarted, "paypal:vault-tokenize:started")
        XCTAssertEqual(BTPayPalAnalytics.checkoutRequestStarted, "paypal:checkout-tokenize:started")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeFailed, "paypal:tokenize:failed")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeSucceeded, "paypal:tokenize:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserLoginCanceled, "paypal:tokenize:browser-login:canceled")
        XCTAssertEqual(BTPayPalAnalytics.tokenizeNetworkConnectionFailed, "paypal:tokenize:network-connection:failed")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationStarted, "paypal:tokenize:browser-presentation:started")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationSucceeded, "paypal:tokenize:browser-presentation:succeeded")
        XCTAssertEqual(BTPayPalAnalytics.browserPresentationFailed, "paypal:tokenize:browser-presentation:failed")
        XCTAssertEqual(BTPayPalAnalytics.websessionBrowserCancel, "paypal:tokenize:websession-browser:canceled")
        XCTAssertEqual(BTPayPalAnalytics.websessionAlertCancel, "paypal:tokenize:websession-alert:canceled")        
    }
}
