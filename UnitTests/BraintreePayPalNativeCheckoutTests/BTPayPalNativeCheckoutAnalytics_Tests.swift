import XCTest
@testable import BraintreePayPalNativeCheckout

final class BTPayPalNativeCheckoutAnalytics_tests: XCTestCase {
    func test_tokenizeAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.vaultRequestStarted, "paypal-native:vault-tokenize:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.checkoutRequestStarted, "paypal-native:checkout-tokenize:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeFailed, "paypal-native:tokenize:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeSucceeded, "paypal-native:tokenize:succeeded")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeCanceled, "paypal-native:tokenize:canceled")
    }
}
