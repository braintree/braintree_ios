import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingColor_Tests: XCTestCase {

    func testColor_withBlack_returnsRawValueBlack() {
        XCTAssertEqual(BTPayPalMessagingColor.black.messageColorRawValue, .black)
    }

    func testColor_withWhite_returnsRawValueWhite() {
        XCTAssertEqual(BTPayPalMessagingColor.white.messageColorRawValue, .white)
    }

    func testColor_withMonochrome_returnsRawValueMonochrome() {
        XCTAssertEqual(BTPayPalMessagingColor.monochrome.messageColorRawValue, .monochrome)
    }

    func testColor_withGreyscale_returnsRawValueGreyscale() {
        XCTAssertEqual(BTPayPalMessagingColor.grayscale.messageColorRawValue, .grayscale)
    }
}
