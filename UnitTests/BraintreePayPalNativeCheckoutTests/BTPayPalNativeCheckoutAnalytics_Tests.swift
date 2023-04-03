import XCTest
@testable import BraintreePayPalNativeCheckout

final class BTPayPalNativeCheckoutAnalytics_Tests: XCTestCase {
    func test_tokenizeAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeStarted, "paypal-native:tokenize:started")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeFailed, "paypal-native:tokenize:failed")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeSucceeded, "paypal-native:tokenize:succeeded")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.tokenizeCanceled, "paypal-native:tokenize:canceled")
        XCTAssertEqual(BTPayPalNativeCheckoutAnalytics.orderCreationFailed, "paypal-native:tokenize:order-creation:failed")
    }
}
