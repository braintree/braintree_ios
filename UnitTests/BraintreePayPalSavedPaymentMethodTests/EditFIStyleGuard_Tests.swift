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

    func testTextSizes_whenUnset_fallBackToTheSDKDefault() {
        XCTAssertEqual(EditFIStyleGuard.labelFontSize(nil, base: nil), EditFIStyleGuard.Defaults.labelFontSize)
        XCTAssertEqual(
            EditFIStyleGuard.fundingInstrumentTextFontSize(nil, base: nil),
            EditFIStyleGuard.Defaults.fundingInstrumentTextFontSize
        )
        XCTAssertEqual(
            EditFIStyleGuard.creditMessageFontSize(nil, base: nil),
            EditFIStyleGuard.Defaults.creditMessageFontSize
        )
    }

    func testTextSizes_whenOnlyBaseFontSizeIsSet_useTheBase() {
        XCTAssertEqual(EditFIStyleGuard.labelFontSize(nil, base: 30), 30)
        XCTAssertEqual(EditFIStyleGuard.fundingInstrumentTextFontSize(nil, base: 30), 30)
        XCTAssertEqual(EditFIStyleGuard.creditMessageFontSize(nil, base: 30), 30)
    }

    func testTextSizes_whenTheFieldIsSet_itWinsOverTheBase() {
        XCTAssertEqual(EditFIStyleGuard.labelFontSize(11, base: 30), 11)
        XCTAssertEqual(EditFIStyleGuard.fundingInstrumentTextFontSize(11, base: 30), 11)
        XCTAssertEqual(EditFIStyleGuard.creditMessageFontSize(11, base: 30), 11)
    }

    func testTextSizes_whenNegative_areClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.labelFontSize(-5, base: nil), 0)
        XCTAssertEqual(EditFIStyleGuard.fundingInstrumentTextFontSize(-5, base: nil), 0)
        XCTAssertEqual(EditFIStyleGuard.creditMessageFontSize(-5, base: nil), 0)
    }

    func testTextSizes_whenBaseIsNegative_areClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.labelFontSize(nil, base: -5), 0)
    }

    // MARK: - Spacing and sizing

    func testSpacing_whenUnset_fallsBackToTheSDKDefault() {
        XCTAssertEqual(EditFIStyleGuard.labelLeadingGap(nil), EditFIStyleGuard.Defaults.labelLeadingGap)
        XCTAssertEqual(
            EditFIStyleGuard.fundingInstrumentLeadingGap(nil),
            EditFIStyleGuard.Defaults.fundingInstrumentLeadingGap
        )
        XCTAssertEqual(EditFIStyleGuard.editIconSize(nil), EditFIStyleGuard.Defaults.editIconSize)
        XCTAssertEqual(EditFIStyleGuard.horizontalPadding(nil), EditFIStyleGuard.Defaults.containerHorizontalPadding)
        XCTAssertEqual(EditFIStyleGuard.verticalPadding(nil), EditFIStyleGuard.Defaults.containerVerticalPadding)
        XCTAssertEqual(EditFIStyleGuard.cornerRadius(nil), EditFIStyleGuard.Defaults.containerCornerRadius)
        XCTAssertEqual(EditFIStyleGuard.borderWidth(nil), EditFIStyleGuard.Defaults.containerBorderWidth)
    }

    func testSpacing_whenSet_returnsTheMerchantValue() {
        XCTAssertEqual(EditFIStyleGuard.labelLeadingGap(4), 4)
        XCTAssertEqual(EditFIStyleGuard.fundingInstrumentLeadingGap(4), 4)
        XCTAssertEqual(EditFIStyleGuard.editIconSize(4), 4)
        XCTAssertEqual(EditFIStyleGuard.logoWidth(4), 4)
        XCTAssertEqual(EditFIStyleGuard.horizontalPadding(4), 4)
        XCTAssertEqual(EditFIStyleGuard.verticalPadding(4), 4)
        XCTAssertEqual(EditFIStyleGuard.cornerRadius(4), 4)
        XCTAssertEqual(EditFIStyleGuard.borderWidth(4), 4)
    }

    /// Negative geometry throws inside SwiftUI, so every dimension is clamped rather than passed through.
    func testSpacing_whenNegative_isClampedToZero() {
        XCTAssertEqual(EditFIStyleGuard.labelLeadingGap(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.fundingInstrumentLeadingGap(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.editIconSize(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.logoWidth(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.horizontalPadding(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.verticalPadding(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.cornerRadius(-1), 0)
        XCTAssertEqual(EditFIStyleGuard.borderWidth(-1), 0)
    }

    func testSpacing_whenZero_isPreserved() {
        XCTAssertEqual(EditFIStyleGuard.labelLeadingGap(0), 0)
        XCTAssertEqual(EditFIStyleGuard.editIconSize(0), 0)
        XCTAssertEqual(EditFIStyleGuard.borderWidth(0), 0)
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
