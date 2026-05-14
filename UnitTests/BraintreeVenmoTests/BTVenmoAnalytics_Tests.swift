import XCTest
@testable import BraintreeVenmo

final class BTVenmoAnalytics_Tests: XCTestCase {
    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTVenmoAnalytics.tokenizeStarted, "venmo:tokenize:started")
        XCTAssertEqual(BTVenmoAnalytics.tokenizeFailed, "venmo:tokenize:failed")
        XCTAssertEqual(BTVenmoAnalytics.tokenizeSucceeded, "venmo:tokenize:succeeded")
        XCTAssertEqual(BTVenmoAnalytics.appSwitchSucceeded, "venmo:tokenize:app-switch:succeeded")
        XCTAssertEqual(BTVenmoAnalytics.appSwitchFailed, "venmo:tokenize:app-switch:failed")
        XCTAssertEqual(BTVenmoAnalytics.appSwitchCanceled, "venmo:tokenize:app-switch:canceled")
        XCTAssertEqual(BTVenmoAnalytics.createPaymentContextStarted, "venmo:create-payment-context:started")
        XCTAssertEqual(BTVenmoAnalytics.createPaymentContextSucceeded, "venmo:create-payment-context:succeeded")
        XCTAssertEqual(BTVenmoAnalytics.createPaymentContextFailed, "venmo:create-payment-context:failed")
        XCTAssertEqual(BTVenmoAnalytics.queryPaymentContextStarted, "venmo:query-payment-context:started")
        XCTAssertEqual(BTVenmoAnalytics.queryPaymentContextSucceeded, "venmo:query-payment-context:succeeded")
        XCTAssertEqual(BTVenmoAnalytics.queryPaymentContextFailed, "venmo:query-payment-context:failed")
    }
}
