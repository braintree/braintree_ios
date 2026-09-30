import XCTest
import UIKit
@testable import BraintreePayPalSavedPaymentMethod

final class EditFIStyleGuard_Tests: XCTestCase {

    // MARK: - Colors

    func testColors_whenMerchantLeavesThemNil_returnTheSDKDefaults() {
        XCTAssertEqual(EditFIStyleGuard.backgroundColor(nil), EditFIStyleGuard.Defaults.backgroundColor)
        XCTAssertEqual(EditFIStyleGuard.textColor(nil), EditFIStyleGuard.Defaults.textColor)
        XCTAssertEqual(EditFIStyleGuard.containerBorderColor(nil), EditFIStyleGuard.Defaults.containerBorderColor)
    }

    func testColors_whenMerchantSuppliesThem_returnTheMerchantValue() {
        XCTAssertEqual(EditFIStyleGuard.backgroundColor(.red), .red)
        XCTAssertEqual(EditFIStyleGuard.textColor(.green), .green)
        XCTAssertEqual(EditFIStyleGuard.containerBorderColor(.blue), .blue)
    }

    // MARK: - Text sizes

    func testFontSize_whenUnset_fallsBackToTheDefault() {
        XCTAssertEqual(EditFIStyleGuard.fontSize(nil, base: nil, default: 20), 20)
    }

    func testFontSize_whenOnlyBaseFontSizeIsSet_usesTheBase() {
        XCTAssertEqual(EditFIStyleGuard.fontSize(nil, base: 30, default: 20), 30)
    }

    func testFontSize_whenTheFieldIsSet_itWinsOverTheBase() {
        XCTAssertEqual(EditFIStyleGuard.fontSize(11, base: 30, default: 20), 11)
    }

    func testFontSize_whenTheFieldOrBaseIsNegative_isClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.fontSize(-5, base: nil, default: 20), 0)
        XCTAssertEqual(EditFIStyleGuard.fontSize(nil, base: -5, default: 20), 0)
    }

    // MARK: - Spacing and sizing

    func testDimension_whenUnset_fallsBackToTheDefault() {
        XCTAssertEqual(EditFIStyleGuard.dimension(nil, default: 12.73), 12.73)
    }

    func testDimension_whenSet_returnsTheMerchantValue() {
        XCTAssertEqual(EditFIStyleGuard.dimension(4, default: 12.73), 4)
    }

    /// Negative geometry throws inside SwiftUI, so every dimension is clamped rather than passed through.
    func testDimension_whenNegative_isClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.dimension(-1, default: 12.73), 0)
    }

    func testDimension_whenZero_isPreserved() {
        XCTAssertEqual(EditFIStyleGuard.dimension(0, default: 12.73), 0)
    }

    // MARK: - Container height

    func testContainerHeight_whenUnset_staysNilToKeepTheIntrinsicHeight() {
        XCTAssertNil(EditFIStyleGuard.containerHeight(nil))
    }

    func testContainerHeight_whenSet_returnsTheMerchantValue() {
        XCTAssertEqual(EditFIStyleGuard.containerHeight(80), 80)
        XCTAssertEqual(EditFIStyleGuard.containerHeight(0), 0)
    }

    func testContainerHeight_whenNegative_isClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.containerHeight(-100), 0)
    }
}
