import XCTest
@testable import BraintreePayPalNativeCheckout

final class BTPayPalNativeCheckoutAnalytics_tests: XCTestCase {
    func test_tokenizeAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.vaultRequestStarted, "paypal-native:vault-tokenize:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.checkoutRequestStarted, "paypal-native:checkout-tokenize:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeFailed, "paypal-native:tokenize:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeSucceeded, "paypal-native:tokenize:succeeded")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeCanceled, "paypal-native:tokenize:canceled")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeUrlRequestFailed, "paypal-native:tokenize:url-request:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeParsingResultFailed, "paypal-native:tokenize:parsing-result:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderStarted, "paypal-native:create-order:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderFailed, "paypal-native:create-order:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderSucceeded, "paypal-native:create-order:succeeded")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderPayPalNotEnabledFailed, "paypal-native:create-order:paypal-not-enabled:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderClientIdNotFoundFailed, "paypal-native:create-order:client-id-not-found:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderInvalidEnvironmentFailed, "paypal-native:create-order:invalid-environment:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderHermesUrlRequestFailed, "paypal-native:create-order:hermes-url-request:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.createOrderInvalidPaymentType, "paypal-native:create-order:invalid-payment-type:failed")
    }
}
