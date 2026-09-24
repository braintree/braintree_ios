import SwiftUI
import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodFont_Tests: XCTestCase {

    /// An empty string is treated as "no custom font" rather than being passed to
    /// `Font.custom`, which would resolve to an unpredictable fallback face.
    func testFont_withEmptyName_fallsBackToSystemFont() {
        XCTAssertEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "", size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14)
        )
    }

    func testFont_withCustomName_differsFromSystemFont() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "Georgia", size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14)
        )
    }

    func testFont_weightIsAppliedToCustomFonts() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "HelveticaNeue", size: 14, weight: .bold),
            BTPayPalSavedPaymentMethodFont.font(name: "HelveticaNeue", size: 14, weight: .regular)
        )
    }

    func testFont_weightIsAppliedToSystemFonts() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, weight: .bold),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, weight: .regular)
        )
    }
}
