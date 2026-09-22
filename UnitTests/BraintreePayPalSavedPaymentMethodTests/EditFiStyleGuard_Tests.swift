import XCTest
import UIKit
@testable import BraintreePayPalSavedPaymentMethod

final class EditFiStyleGuard_Tests: XCTestCase {

    // MARK: - Colors

    func testColors_whenMerchantLeavesThemNil_returnTheSDKDefaults() {
        XCTAssertEqual(EditFiStyleGuard.backgroundColor(nil), EditFiStyleGuard.Defaults.backgroundColor)
        XCTAssertEqual(EditFiStyleGuard.textColor(nil), EditFiStyleGuard.Defaults.textColor)
        XCTAssertEqual(EditFiStyleGuard.containerBorderColor(nil), EditFiStyleGuard.Defaults.containerBorderColor)
    }

    func testColors_whenMerchantSuppliesThem_returnTheMerchantValue() {
        XCTAssertEqual(EditFiStyleGuard.backgroundColor(.red), .red)
        XCTAssertEqual(EditFiStyleGuard.textColor(.green), .green)
        XCTAssertEqual(EditFiStyleGuard.containerBorderColor(.blue), .blue)
    }

    // MARK: - Text sizes

    func testTextSizes_whenUnset_fallBackToTheSDKDefault() {
        XCTAssertEqual(EditFiStyleGuard.labelFontSize(nil, base: nil), EditFiStyleGuard.Defaults.labelFontSize)
        XCTAssertEqual(
            EditFiStyleGuard.fundingInstrumentTextFontSize(nil, base: nil),
            EditFiStyleGuard.Defaults.fundingInstrumentTextFontSize
        )
        XCTAssertEqual(
            EditFiStyleGuard.creditMessageFontSize(nil, base: nil),
            EditFiStyleGuard.Defaults.creditMessageFontSize
        )
    }

    func testTextSizes_whenOnlyBaseFontSizeIsSet_useTheBase() {
        XCTAssertEqual(EditFiStyleGuard.labelFontSize(nil, base: 30), 30)
        XCTAssertEqual(EditFiStyleGuard.fundingInstrumentTextFontSize(nil, base: 30), 30)
        XCTAssertEqual(EditFiStyleGuard.creditMessageFontSize(nil, base: 30), 30)
    }

    func testTextSizes_whenTheFieldIsSet_itWinsOverTheBase() {
        XCTAssertEqual(EditFiStyleGuard.labelFontSize(11, base: 30), 11)
        XCTAssertEqual(EditFiStyleGuard.fundingInstrumentTextFontSize(11, base: 30), 11)
        XCTAssertEqual(EditFiStyleGuard.creditMessageFontSize(11, base: 30), 11)
    }

    func testTextSizes_whenNegative_areClampedToZero() {
        XCTAssertEqual(EditFiStyleGuard.labelFontSize(-5, base: nil), 0)
        XCTAssertEqual(EditFiStyleGuard.fundingInstrumentTextFontSize(-5, base: nil), 0)
        XCTAssertEqual(EditFiStyleGuard.creditMessageFontSize(-5, base: nil), 0)
    }

    func testTextSizes_whenBaseIsNegative_areClampedToZero() {
        XCTAssertEqual(EditFiStyleGuard.labelFontSize(nil, base: -5), 0)
    }

    // MARK: - Spacing and sizing

    func testSpacing_whenUnset_fallsBackToTheSDKDefault() {
        XCTAssertEqual(EditFiStyleGuard.labelLeadingGap(nil), EditFiStyleGuard.Defaults.labelLeadingGap)
        XCTAssertEqual(
            EditFiStyleGuard.fundingInstrumentLeadingGap(nil),
            EditFiStyleGuard.Defaults.fundingInstrumentLeadingGap
        )
        XCTAssertEqual(EditFiStyleGuard.editIconSize(nil), EditFiStyleGuard.Defaults.editIconSize)
        XCTAssertEqual(EditFiStyleGuard.horizontalPadding(nil), EditFiStyleGuard.Defaults.containerHorizontalPadding)
        XCTAssertEqual(EditFiStyleGuard.verticalPadding(nil), EditFiStyleGuard.Defaults.containerVerticalPadding)
        XCTAssertEqual(EditFiStyleGuard.cornerRadius(nil), EditFiStyleGuard.Defaults.containerCornerRadius)
        XCTAssertEqual(EditFiStyleGuard.borderWidth(nil), EditFiStyleGuard.Defaults.containerBorderWidth)
    }

    func testSpacing_whenSet_returnsTheMerchantValue() {
        XCTAssertEqual(EditFiStyleGuard.labelLeadingGap(4), 4)
        XCTAssertEqual(EditFiStyleGuard.fundingInstrumentLeadingGap(4), 4)
        XCTAssertEqual(EditFiStyleGuard.editIconSize(4), 4)
        XCTAssertEqual(EditFiStyleGuard.logoWidth(4), 4)
        XCTAssertEqual(EditFiStyleGuard.horizontalPadding(4), 4)
        XCTAssertEqual(EditFiStyleGuard.verticalPadding(4), 4)
        XCTAssertEqual(EditFiStyleGuard.cornerRadius(4), 4)
        XCTAssertEqual(EditFiStyleGuard.borderWidth(4), 4)
    }

    /// Negative geometry throws inside SwiftUI, so every dimension is clamped rather than passed through.
    func testSpacing_whenNegative_isClampedToZero() {
        XCTAssertEqual(EditFiStyleGuard.labelLeadingGap(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.fundingInstrumentLeadingGap(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.editIconSize(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.logoWidth(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.horizontalPadding(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.verticalPadding(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.cornerRadius(-1), 0)
        XCTAssertEqual(EditFiStyleGuard.borderWidth(-1), 0)
    }

    func testSpacing_whenZero_isPreserved() {
        XCTAssertEqual(EditFiStyleGuard.labelLeadingGap(0), 0)
        XCTAssertEqual(EditFiStyleGuard.editIconSize(0), 0)
        XCTAssertEqual(EditFiStyleGuard.borderWidth(0), 0)
    }
}
