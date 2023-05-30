import XCTest
@testable import BraintreeApplePay

final class BTApplePayAnalytics_Tests: XCTestCase {

    func test_paymentRequestAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTApplePayAnalytics.paymentRequestStarted, "apple-pay:payment-request:started")
        XCTAssertEqual(BTApplePayAnalytics.paymentRequestFailed, "apple-pay:payment-request:failed")
        XCTAssertEqual(BTApplePayAnalytics.paymentRequestSucceeded, "apple-pay:payment-request:succeeded")
    }

    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTApplePayAnalytics.tokenizeStarted, "apple-pay:tokenize:started")
        XCTAssertEqual(BTApplePayAnalytics.tokenizeFailed, "apple-pay:tokenize:failed")
        XCTAssertEqual(BTApplePayAnalytics.tokenizeSucceeded, "apple-pay:tokenize:succeeded")
    }
}
