import XCTest
@testable import BraintreePaymentFlow

final class BTPaymentFlow_Tests: XCTestCase {

    func test_startPaymentAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentStarted, "local-payment:start-payment:started")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentSucceeded, "local-payment:start-payment:succeeded")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentFailed, "local-payment:start-payment:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentCanceled, "local-payment:start-payment:browser-login:canceled")

        XCTAssertEqual(BTPaymentFlowAnalytics.browserPresentationSucceeded, "local-payment:start-payment:browser-presentation:succeeded")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserPresentationFailed, "local-payment:start-payment:browser-presentation:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserLoginAlertCanceled, "local-payment:start-payment:browser-login:alert-canceled")
        XCTAssertEqual(BTPaymentFlowAnalytics.browserLoginFailed, "local-payment:start-payment:browser-login:failed")
        XCTAssertEqual(BTPaymentFlowAnalytics.paymentNetworkConnectionLost, "local-payment:start-payment:network-connection:failed")
    }
}

