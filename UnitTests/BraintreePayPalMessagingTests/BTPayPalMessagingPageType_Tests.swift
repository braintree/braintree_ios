import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingPageType_Tests: XCTestCase {

    func testPageType_withHome_returnsPageTypeHome() {
        XCTAssertEqual(BTPayPalMessagingPageType.home.pageTypeRawValue, .home)
    }

    func testPageType_withCategory_returnsPageTypeProductDetails() {
        XCTAssertEqual(BTPayPalMessagingPageType.productDetails.pageTypeRawValue, .productDetails)
    }

    func testPageType_withProduct_returnsPageTypeCart() {
        XCTAssertEqual(BTPayPalMessagingPageType.cart.pageTypeRawValue, .cart)
    }

    func testPageType_withCart_returnsPageTypeMiniCart() {
        XCTAssertEqual(BTPayPalMessagingPageType.miniCart.pageTypeRawValue, .miniCart)
    }

    func testPageType_withPayment_returnsPageTypeCheckout() {
        XCTAssertEqual(BTPayPalMessagingPageType.checkout.pageTypeRawValue, .checkout)
    }
    
    func testPageType_withSearchResults_returnsPageTypeSearchResults() {
        XCTAssertEqual(BTPayPalMessagingPageType.searchResults.pageTypeRawValue, .searchResults)
    }
}
