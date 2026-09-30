import SwiftUI
import XCTest
@testable import BraintreePayPalSavedPaymentMethod

/// Renders the composed view in every state and style permutation.
final class BTPayPalSavedPaymentMethodView_RenderTests: SavedPaymentMethodRenderTestCase {

    // MARK: - Helpers

    private func view(
        state: BTPayPalSavedPaymentMethodViewModel.FIState,
        showCreditMessage: Bool = false,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) -> BTPayPalSavedPaymentMethodView {
        BTPayPalSavedPaymentMethodView(
            viewModel: BTPayPalSavedPaymentMethodViewModel(
                previewState: state,
                showCreditMessage: showCreditMessage
            ),
            style: style
        )
    }

    // MARK: - Render states

    /// Every instrument shape the API can return. These share one render path, so they are driven
    /// from a table rather than repeated as separate tests.
    func testRender_everyInstrumentVariant() throws {
        let variants: [(name: String, fi: BTPayPalSavedPaymentMethod)] = [
            ("card", try instrument()),
            ("card with remote art", try instrument(imageURL: "https://example.com/visa.png")),
            ("card without art", try instrument(imageURL: nil)),
            ("bank", try instrument(type: "BANK", label: "CREDIT UNION 1", lastDigits: "0199")),
            ("paypal credit", try instrument(type: "PAYPAL_CREDIT", label: "PayPal Credit")),
            ("unrecognised type", try instrument(type: "SOME_FUTURE_TYPE", label: "Mystery")),
            ("missing label and digits", try instrument(label: nil, lastDigits: nil))
        ]

        for variant in variants {
            XCTAssertNotNil(rendered(view(state: .instrument(variant.fi))), variant.name)
        }
    }

    /// The non-instrument states. `.hidden` is asserted separately because it must render nothing.
    func testRender_everyNonInstrumentState() {
        let states: [(name: String, state: BTPayPalSavedPaymentMethodViewModel.FIState)] = [
            ("loading", .loading),
            ("email, editable", .displayOnly(email: "buyer@example.com", isEditable: true)),
            ("email, not editable", .displayOnly(email: "buyer@example.com", isEditable: false)),
            ("brand only", .brandOnly)
        ]

        for entry in states {
            XCTAssertNotNil(rendered(view(state: entry.state)), entry.name)
        }
    }

    func testRender_loadingState_withCreditMessagingDisabled_rendersFISkeletonOnly() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.showPayPalCreditMessaging = false
        try render(view(state: .loading, style: style))
    }

    /// `.hidden` must take up no space at all, not render an empty tile with padding and a border.
    func testRender_hiddenState_occupiesNoSpace() {
        XCTAssertNil(rendered(view(state: .hidden)))
    }

    // MARK: - Style permutations

    /// Merchant style permutations that must all lay out. The cases that collapse the component
    /// are asserted separately below, since they are expected to render nothing.
    func testRender_everyStylePermutation() throws {
        let fi = try instrument()

        var logoAndLabelHidden = BTPayPalSavedPaymentMethodViewStyle()
        logoAndLabelHidden.showPayPalLogo = false
        logoAndLabelHidden.showPayPalLabel = false

        var creditMessagingOff = BTPayPalSavedPaymentMethodViewStyle()
        creditMessagingOff.showPayPalCreditMessaging = false

        var fullyCustomised = BTPayPalSavedPaymentMethodViewStyle()
        fullyCustomised.componentAppearance = .init(
            backgroundColor: .systemPink,
            textColor: .white,
            baseFontSize: 18,
            fontName: "Georgia"
        )
        fullyCustomised.container = .init(
            height: 120,
            horizontalPadding: 20,
            verticalPadding: 12,
            cornerRadius: 16,
            borderColor: .systemBlue,
            borderWidth: 2,
            logo: .init(width: 32),
            label: .init(fontSize: 20, leadingGap: 10),
            fundingInstrument: .init(textFontSize: 16, editIconSize: 24, leadingGap: 8),
            creditMessaging: .init(fontSize: 13, linkColor: .systemGreen)
        )

        // Negative everywhere except height: the guard clamps each value rather than trapping.
        var negatives = BTPayPalSavedPaymentMethodViewStyle()
        negatives.componentAppearance = .init(baseFontSize: -20)
        negatives.container = .init(
            horizontalPadding: -10,
            verticalPadding: -10,
            cornerRadius: -8,
            borderWidth: -4,
            logo: .init(width: -30),
            label: .init(fontSize: -12, leadingGap: -6),
            fundingInstrument: .init(textFontSize: -14, editIconSize: -20, leadingGap: -5),
            creditMessaging: .init(fontSize: -11)
        )

        var zeroPadding = BTPayPalSavedPaymentMethodViewStyle()
        zeroPadding.container = .init(horizontalPadding: 0, verticalPadding: 0, cornerRadius: 0, borderWidth: 0)

        let styles: [(name: String, style: BTPayPalSavedPaymentMethodViewStyle)] = [
            ("logo and label hidden", logoAndLabelHidden),
            ("credit messaging disabled", creditMessagingOff),
            ("fully customised", fullyCustomised),
            ("negative values, intrinsic height", negatives),
            ("zero padding, intrinsic height", zeroPadding)
        ]

        for entry in styles {
            XCTAssertNotNil(
                rendered(view(state: .instrument(fi), showCreditMessage: true, style: entry.style)),
                entry.name
            )
        }
    }

    /// `EditFIStyleGuard` clamps negatives to zero so a merchant can never hand SwiftUI a
    /// negative frame. An explicit negative height collapses the component rather than trapping.
    func testRender_withNegativeHeight_collapsesInsteadOfTrapping() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container = .init(height: -100)

        XCTAssertEqual(EditFIStyleGuard.containerHeight(-100), 0)
        XCTAssertNil(rendered(view(state: .instrument(try instrument()), showCreditMessage: true, style: style)))
    }

    func testRender_withZeroHeight_collapsesComponent() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container = .init(height: 0, horizontalPadding: 0, verticalPadding: 0, cornerRadius: 0, borderWidth: 0)
        XCTAssertNil(rendered(view(state: .instrument(try instrument()), style: style)))
    }

    func testRender_everyStateWithCustomFont() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.componentAppearance = .init(fontName: "HelveticaNeue")

        let states: [BTPayPalSavedPaymentMethodViewModel.FIState] = [
            .loading,
            .instrument(try instrument()),
            .displayOnly(email: "buyer@example.com", isEditable: true),
            .brandOnly
        ]

        for state in states {
            try render(view(state: state, showCreditMessage: true, style: style))
        }
    }

    // MARK: - Loading placeholders

    func testRender_skeletonRow() throws {
        try render(BTPayPalSavedPaymentMethodSkeletonRow(style: BTPayPalSavedPaymentMethodViewStyle()))
    }

    func testRender_creditMessageSkeleton() throws {
        try render(CreditMessageSkeleton())
    }

    // MARK: - Assets

    func testBundle_containsTheLoadingSpinner() {
        XCTAssertNotNil(UIImage(named: "LoadingSpinner", in: .payPalSavedPaymentMethod, compatibleWith: nil))
    }
}
