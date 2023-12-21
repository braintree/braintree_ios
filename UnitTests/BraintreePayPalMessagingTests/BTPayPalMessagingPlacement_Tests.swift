import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingPlacement_Tests: XCTestCase {

    func testPlacement_withHome_returnsRawValueHome() {
        XCTAssertEqual(BTPayPalMessagingPlacement.home.placementRawValue, .home)
    }

    func testPlacement_withCategory_returnsRawValueCategory() {
        XCTAssertEqual(BTPayPalMessagingPlacement.category.placementRawValue, .category)
    }

    func testPlacement_withProduct_returnsRawValueProduct() {
        XCTAssertEqual(BTPayPalMessagingPlacement.product.placementRawValue, .product)
    }

    func testPlacement_withCart_returnsRawValueCart() {
        XCTAssertEqual(BTPayPalMessagingPlacement.cart.placementRawValue, .cart)
    }

    func testPlacement_withPayment_returnsRawValuePayment() {
        XCTAssertEqual(BTPayPalMessagingPlacement.payment.placementRawValue, .payment)
    }
}
