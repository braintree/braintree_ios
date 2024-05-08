import XCTest
import PayPalMessages
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingLogoType_Tests: XCTestCase {

    func testLogoType_withInline_returnsRawValueInline() {
        XCTAssertEqual(BTPayPalMessagingLogoType.inline.logoTypeRawValue, .inline)
    }

    func testLogoType_withPrimary_returnsRawValuePrimary() {
        XCTAssertEqual(BTPayPalMessagingLogoType.primary.logoTypeRawValue, .primary)
    }

    func testLogoType_withAlternative_returnsRawValueAlternative() {
        XCTAssertEqual(BTPayPalMessagingLogoType.alternative.logoTypeRawValue, .alternative)
    }

    func testLogoType_withNone_returnsRawValueNone() {
        XCTAssertEqual(BTPayPalMessagingLogoType.none.logoTypeRawValue, .none)
    }
}
