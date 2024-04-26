import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingPageType_Tests: XCTestCase {

    func testPageType_withHome_returnsPageTypeHome() {
        XCTAssertEqual(BTPayPalMessagingPageType.home.pageType, .home)
    }

    func testPageType_withCategory_returnsPageTypeProductDetails() {
        XCTAssertEqual(BTPayPalMessagingPageType.productDetails.pageType, .productDetails)
    }

    func testPageType_withProduct_returnsPageTypeCart() {
        XCTAssertEqual(BTPayPalMessagingPageType.cart.pageType, .cart)
    }

    func testPageType_withCart_returnsPageTypeMiniCart() {
        XCTAssertEqual(BTPayPalMessagingPageType.miniCart.pageType, .miniCart)
    }

    func testPageType_withPayment_returnsPageTypeCheckout() {
        XCTAssertEqual(BTPayPalMessagingPageType.checkout.pageType, .checkout)
    }
    
    func testPageType_withSearchResults_returnsPageTypeSearchResults() {
        XCTAssertEqual(BTPayPalMessagingPageType.searchResults.pageType, .searchResults)
    }
}
