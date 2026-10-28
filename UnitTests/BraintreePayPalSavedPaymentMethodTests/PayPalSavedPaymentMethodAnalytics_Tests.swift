import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class PayPalSavedPaymentMethodAnalytics_Tests: XCTestCase {

    func testInitializationAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.authorizationFailed, "paypal-saved-payment-method:init:authorization-failed")
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.paymentMethodIDRequired,
            "paypal-saved-payment-method:init:payment-method-id-required"
        )
    }

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
