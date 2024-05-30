import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingTextAlignment_Tests: XCTestCase {

    func testTextAlignment_withLeft_returnsRawValueLeft() {
        XCTAssertEqual(BTPayPalMessagingTextAlignment.left.textAlignmentRawValue, .left)
    }

    func testTextAlignment_withCenter_returnsRawValueCenter() {
        XCTAssertEqual(BTPayPalMessagingTextAlignment.center.textAlignmentRawValue, .center)
    }

    func testTextAlignment_withRight_returnsRawValueRight() {
        XCTAssertEqual(BTPayPalMessagingTextAlignment.right.textAlignmentRawValue, .right)
    }
}
