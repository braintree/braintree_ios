import SwiftUI
import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodFont_Tests: XCTestCase {

    /// An empty string is treated as "no custom font" rather than being passed to
    /// `Font.custom`, which would resolve to an unpredictable fallback face.
    func testFont_withEmptyName_fallsBackToSystemFont() {
        XCTAssertEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "", size: 14, dynamicTypeSize: .large),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, dynamicTypeSize: .large)
        )
    }

    func testScaledSize_atTheDefaultDynamicTypeSize_returnsTheBaseSize() {
        XCTAssertEqual(BTPayPalSavedPaymentMethodFont.scaledSize(14, for: .large), 14, accuracy: 0.01)
    }

    func testScaledSize_growsWithEachLargerDynamicTypeSize() {
        let sizes = DynamicTypeSize.allCases.map { BTPayPalSavedPaymentMethodFont.scaledSize(14, for: $0) }

        for (smaller, larger) in zip(sizes, sizes.dropFirst()) {
            XCTAssertLessThan(smaller, larger)
        }
    }

    /// Guards against scaling by the app-wide setting, which ignores a merchant's `.dynamicTypeSize(...)` limit.
    func testFont_withSystemFont_scalesByThePassedDynamicTypeSize() {
        let font = BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, dynamicTypeSize: .accessibility3)

        XCTAssertEqual(
            font,
            .system(size: BTPayPalSavedPaymentMethodFont.scaledSize(14, for: .accessibility3), weight: .regular)
        )
        XCTAssertNotEqual(font, BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, dynamicTypeSize: .large))
    }
}
