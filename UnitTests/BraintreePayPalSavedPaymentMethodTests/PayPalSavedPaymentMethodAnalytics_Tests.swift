import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class PayPalSavedPaymentMethodAnalytics_Tests: XCTestCase {

    func testFundingInstrumentAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.stickyFIFetchStarted, "paypal-saved-payment-method:sticky-fi:fetch-started")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.stickyFIFetchSucceeded, "paypal-saved-payment-method:sticky-fi:fetch-succeeded")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.stickyFIFetchFailed, "paypal-saved-payment-method:sticky-fi:fetch-failed")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.fiRefreshStarted, "paypal-saved-payment-method:fi-refresh:started")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.fiRefreshSucceeded, "paypal-saved-payment-method:fi-refresh:succeeded")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.fiRefreshFailed, "paypal-saved-payment-method:fi-refresh:failed")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.renderSucceeded, "paypal-saved-payment-method:render:succeeded")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.editSelected, "paypal-saved-payment-method:edit:selected")
    }

    func testCreditMessagingAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingFetchStarted,
            "paypal-saved-payment-method:credit-messaging:fetch-started"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingFetchSucceeded,
            "paypal-saved-payment-method:credit-messaging:fetch-succeeded"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingFetchFailed,
            "paypal-saved-payment-method:credit-messaging:fetch-failed"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingRenderSucceeded,
            "paypal-saved-payment-method:credit-messaging:render-succeeded"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingLearnMoreSelected,
            "paypal-saved-payment-method:credit-messaging-learn-more:selected"
        )
    }
}
