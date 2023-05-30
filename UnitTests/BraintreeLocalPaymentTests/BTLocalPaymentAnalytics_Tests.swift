import XCTest
@testable import BraintreeLocalPayment

final class BTLocalPaymentAnalytics_Tests: XCTestCase {

    func test_startPaymentAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTLocalPaymentAnalytics.paymentStarted, "local-payment:start-payment:started")
        XCTAssertEqual(BTLocalPaymentAnalytics.paymentSucceeded, "local-payment:start-payment:succeeded")
        XCTAssertEqual(BTLocalPaymentAnalytics.paymentFailed, "local-payment:start-payment:failed")
        XCTAssertEqual(BTLocalPaymentAnalytics.paymentCanceled, "local-payment:start-payment:browser-login:canceled")

        XCTAssertEqual(BTLocalPaymentAnalytics.browserPresentationSucceeded, "local-payment:start-payment:browser-presentation:succeeded")
        XCTAssertEqual(BTLocalPaymentAnalytics.browserPresentationFailed, "local-payment:start-payment:browser-presentation:failed")
        XCTAssertEqual(BTLocalPaymentAnalytics.browserLoginAlertCanceled, "local-payment:start-payment:browser-login:alert-canceled")
        XCTAssertEqual(BTLocalPaymentAnalytics.browserLoginFailed, "local-payment:start-payment:browser-login:failed")
    }
}
