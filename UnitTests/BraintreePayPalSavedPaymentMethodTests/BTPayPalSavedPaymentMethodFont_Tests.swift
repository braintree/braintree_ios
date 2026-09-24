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
}
