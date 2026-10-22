import SafariServices
import SwiftUI
import XCTest
@testable import BraintreePayPalSavedPaymentMethod

/// Renders the composed view in every state and style permutation.
final class PayPalSavedPaymentMethodView_RenderTests: SavedPaymentMethodRenderTestCase {

    // MARK: - Helpers

    private func view(
        state: PayPalSavedPaymentMethodViewModel.FIState,
        showCreditMessage: Bool = false,
        style: PayPalSavedPaymentMethodViewStyle = PayPalSavedPaymentMethodViewStyle()
    ) -> PayPalSavedPaymentMethodView {
        let creditMessage = CreditMessageContent(
            message: "Or 4 interest-free payments of $324.50.",
            learnMore: URL(string: "https://example.com/lander").map {
                CreditMessageContent.LearnMore(text: "Learn more", url: $0, isEmbeddable: false)
            }
        )
        return PayPalSavedPaymentMethodView(
            viewModel: PayPalSavedPaymentMethodViewModel(
                previewState: state,
                creditMessage: showCreditMessage ? creditMessage : nil
            ),
            style: style
        )
    }

    // MARK: - Render states

    /// Every instrument shape the API can return. These share one render path, so they are driven
    /// from a table rather than repeated as separate tests.
    func testRender_everyInstrumentVariant() throws {
        let variants: [(name: String, fi: PayPalSavedPaymentMethod)] = [
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

    /// The non-instrument states.
    func testRender_everyNonInstrumentState() {
        let states: [(name: String, state: PayPalSavedPaymentMethodViewModel.FIState)] = [
            ("loading", .loading),
            ("email, editable", .displayOnly(email: "buyer@example.com", isEditable: true)),
            ("email, not editable", .displayOnly(email: "buyer@example.com", isEditable: false)),
            ("brand only", .brandOnly)
        ]

        for entry in states {
            XCTAssertNotNil(rendered(view(state: entry.state)), entry.name)
        }
    }

    /// With the logo and label both hidden, brand-only has nothing to show, so it must not render an empty tile.
    func testRender_brandOnly_withLogoAndLabelHidden_occupiesNoSpace() {
        let style = PayPalSavedPaymentMethodViewStyle(showPayPalLogo: false, showPayPalLabel: false)

        XCTAssertNil(rendered(view(state: .brandOnly, style: style)))
    }

    // MARK: - Rendered content

    func testRender_withACreditMessage_isTallerThanWithout() throws {
        let fi = try instrument()

        let withMessage = try render(view(state: .instrument(fi), showCreditMessage: true))
        let withoutMessage = try render(view(state: .instrument(fi)))

        XCTAssertGreaterThan(withMessage.size.height, withoutMessage.size.height)
    }

    /// Brand-only shows both the logo and the label, and each one respects its style flag.
    func testRender_brandOnly_drawsTheLogoAndTheLabel() throws {
        let both = try render(view(state: .brandOnly)).pngData()
        let logoOnly = try render(view(state: .brandOnly, style: .init(showPayPalLabel: false))).pngData()
        let labelOnly = try render(view(state: .brandOnly, style: .init(showPayPalLogo: false))).pngData()

        XCTAssertNotEqual(both, logoOnly)
        XCTAssertNotEqual(both, labelOnly)
        XCTAssertNotEqual(logoOnly, labelOnly)
    }

    func testRender_editableEmail_drawsTheEditPencil() throws {
        let editable = try render(view(state: .displayOnly(email: "buyer@example.com", isEditable: true))).pngData()
        let readOnly = try render(view(state: .displayOnly(email: "buyer@example.com", isEditable: false))).pngData()

        XCTAssertNotEqual(editable, readOnly)
    }

    // MARK: - Style permutations

    /// Merchant style permutations that must all lay out. The cases that collapse the component
    /// are asserted separately below, since they are expected to render nothing.
    func testRender_everyStylePermutation() throws {
        let fi = try instrument()

        let logoAndLabelHidden = PayPalSavedPaymentMethodViewStyle(showPayPalLogo: false, showPayPalLabel: false)

        let creditMessagingOff = PayPalSavedPaymentMethodViewStyle(showPayPalCreditMessaging: false)

        let fullyCustomised = PayPalSavedPaymentMethodViewStyle(
            componentAppearance: .init(
                backgroundColor: .systemPink,
                textColor: .white,
                baseFontSize: 18,
                fontName: "Georgia"
            ),
            container: .init(
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
        )

        // Negative everywhere except height: the guard clamps each value rather than trapping.
        let negatives = PayPalSavedPaymentMethodViewStyle(
            componentAppearance: .init(baseFontSize: -20),
            container: .init(
                horizontalPadding: -10,
                verticalPadding: -10,
                cornerRadius: -8,
                borderWidth: -4,
                logo: .init(width: -30),
                label: .init(fontSize: -12, leadingGap: -6),
                fundingInstrument: .init(textFontSize: -14, editIconSize: -20, leadingGap: -5),
                creditMessaging: .init(fontSize: -11)
            )
        )

        let zeroPadding = PayPalSavedPaymentMethodViewStyle(
            container: .init(horizontalPadding: 0, verticalPadding: 0, cornerRadius: 0, borderWidth: 0)
        )

        let styles: [(name: String, style: PayPalSavedPaymentMethodViewStyle)] = [
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
        let style = PayPalSavedPaymentMethodViewStyle(container: .init(height: -100))

        XCTAssertEqual(EditFIStyleGuard.containerHeight(-100), 0)
        XCTAssertNil(rendered(view(state: .instrument(try instrument()), showCreditMessage: true, style: style)))
    }

    // MARK: - Lander

    /// Safari's "Done" button must clear the presenter's state, or the sheet can't be shown again.
    func testLander_whenSafariFinishes_callsOnFinish() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/lander"))
        var didFinish = false
        let coordinator = PayPalCreditMessagingLanderView(url: url) { didFinish = true }.makeCoordinator()

        coordinator.safariViewControllerDidFinish(SFSafariViewController(url: url))

        XCTAssertTrue(didFinish)
    }
}
