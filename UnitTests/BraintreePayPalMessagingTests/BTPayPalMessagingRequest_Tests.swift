import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingRequest_Tests: XCTestCase {

    func testPayPalMessagingRequest_withEmptyInit_setsAllValuesToDefault() {
        let request = BTPayPalMessagingRequest()

        XCTAssertNil(request.amount)
        XCTAssertNil(request.pageType)
        XCTAssertNil(request.offerType)
        XCTAssertNil(request.buyerCountry)
        XCTAssertEqual(request.logoType, .inline)
        XCTAssertEqual(request.textAlignment, .right)
        XCTAssertEqual(request.color, .black)
    }

    func testPayPalMessagingRequest_withAllValuesInitialized_setsAllValues() {
        let request = BTPayPalMessagingRequest(
            amount: 6.66,
            pageType: .home,
            offerType: .payPalCreditNoInterest,
            buyerCountry: "US",
            logoType: .alternative,
            textAlignment: .center,
            color: .white
        )

        XCTAssertEqual(request.amount, 6.66)
        XCTAssertEqual(request.pageType, .home)
        XCTAssertEqual(request.offerType, .payPalCreditNoInterest)
        XCTAssertEqual(request.buyerCountry, "US")
        XCTAssertEqual(request.logoType, .alternative)
        XCTAssertEqual(request.textAlignment, .center)
        XCTAssertEqual(request.color, .white)
    }
}
