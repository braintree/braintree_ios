import XCTest
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutAnalytics_Tests: XCTestCase {

    func test_getVisaCheckoutAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTVisaCheckoutAnalytics.tokenizeStarted, "visa-checkout:tokenize:started")
        XCTAssertEqual(BTVisaCheckoutAnalytics.tokenizeFailed, "visa-checkout:tokenize:failed")
        XCTAssertEqual(BTVisaCheckoutAnalytics.tokenizeSucceeded, "visa-checkout:tokenize:succeeded")
    }
}
