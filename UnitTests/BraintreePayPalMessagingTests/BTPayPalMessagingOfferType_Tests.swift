import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingOfferType_Tests: XCTestCase {

    func testOfferType_withPayLaterShortTerm_returnsRawValuePayLaterShortTerm() {
        XCTAssertEqual(BTPayPalMessagingOfferType.payLaterShortTerm.offerTypeRawValue, .payLaterShortTerm)
    }

    func testOfferType_withPayLaterLongTerm_returnsRawValuePayLaterLongTerm() {
        XCTAssertEqual(BTPayPalMessagingOfferType.payLaterLongTerm.offerTypeRawValue, .payLaterLongTerm)
    }

    func testOfferType_withPayLaterPayInOne_returnsRawValuePayLaterPayIn1() {
        XCTAssertEqual(BTPayPalMessagingOfferType.payLaterPayInOne.offerTypeRawValue, .payLaterPayIn1)
    }

    func testOfferType_withPayPalCreditNoInterest_returnsRawValuePayPalCreditNoInterest() {
        XCTAssertEqual(BTPayPalMessagingOfferType.payPalCreditNoInterest.offerTypeRawValue, .payPalCreditNoInterest)
    }
}
