import XCTest
@testable import BraintreePaymentFlow

final class BTPaymentFlow_Tests: XCTestCase {

    func test_startPaymentAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentStarted, "start-payment:started")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentSucceeded, "start-payment:succeeded")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentFailed, "start-payment:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentCanceled, "start-payment:browser-login:canceled")

        XCTAssertEqual(BTPaymentFlowAnalytics.browserPresentationSucceeded, "start-payment:browser-presentation:succeeded")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserPresentationFailed, "start-payment:browser-presentation:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserLoginAlertCanceled, "start-payment:browser-login:alert-canceled")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserLoginFailed, "start-payment:browser-login:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentNetworkConnectionLost, "start-payment:network-connection:failed")
    }
}


