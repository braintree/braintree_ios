import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class PayPalSavedPaymentMethodAnalytics_Tests: XCTestCase {

    func testRenderAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.renderStarted, "paypal-saved-payment-method:render:started")
        XCTAssertEqual(PayPalSavedPaymentMethodAnalytics.renderPresented, "paypal-saved-payment-method:render:presented")
    }

    func testFundingInstrumentAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.fundingInstrumentPresented,
            "paypal-saved-payment-method:render:funding-instrument:presented"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.fundingInstrumentFailed,
            "paypal-saved-payment-method:render:funding-instrument:failed"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.fundingInstrumentEditSelected,
            "paypal-saved-payment-method:render:funding-instrument-edit:selected"
        )
    }

    func testCreditMessagingAnalyticsEvents_sendExpectedEventNames() {
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingPresented,
            "paypal-saved-payment-method:render:credit-messaging:presented"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingFailed,
            "paypal-saved-payment-method:render:credit-messaging:failed"
        )
        XCTAssertEqual(
            PayPalSavedPaymentMethodAnalytics.creditMessagingLearnMoreSelected,
            "paypal-saved-payment-method:render:credit-messaging-learn-more:selected"
        )
    }
}
