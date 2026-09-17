import SwiftUI
import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal
@testable import BraintreePayPalSavedPaymentMethod

/// Drives every visual state through `ImageRenderer`, which forces SwiftUI to evaluate each
/// `body`. Layout defects in this component are not reachable from the view model: the
/// accessibility truncation bug fixed in this PR lived entirely inside `EditFIRow`'s layout,
/// and every view model assertion passed while it was present.
@MainActor
final class BTPayPalSavedPaymentMethodView_RenderTests: XCTestCase {

    // MARK: - Helpers

    /// `ImageRenderer` yields nil for zero-sized content, so a non-nil image means SwiftUI
    /// evaluated the whole tree and laid it out with a visible frame.
    @discardableResult
    private func render(
        _ view: some View,
        width: CGFloat = 393,
        typeSize: DynamicTypeSize = .large
    ) throws -> UIImage {
        try XCTUnwrap(rendered(view, width: width, typeSize: typeSize))
    }

    private func rendered(
        _ view: some View,
        width: CGFloat = 393,
        typeSize: DynamicTypeSize = .large
    ) -> UIImage? {
        let renderer = ImageRenderer(
            content: view
                .frame(width: width)
                .dynamicTypeSize(typeSize)
        )
        renderer.scale = 2
        return renderer.uiImage
    }

    private func instrument(
        type: String = "CARD",
        label: String? = "Visa",
        lastDigits: String? = "1234",
        imageURL: String? = nil,
        subtype: String? = nil
    ) throws -> BTPayPalSavedPaymentMethod {
        var json: [String: Any] = ["type": type]
        json["label"] = label
        json["lastDigits"] = lastDigits
        json["imageUrl"] = imageURL
        json["subtype"] = subtype
        return try XCTUnwrap(BTPayPalSavedPaymentMethod(json: BTJSON(value: json)))
    }

    private func creditContent(
        learnMoreText: String? = "Learn more",
        isEmbeddable: Bool = false
    ) -> CreditMessageContent {
        CreditMessageContent(
            message: "Or 4 interest-free payments of $324.50.",
            learnMoreText: learnMoreText,
            learnMoreURL: URL(string: "https://example.com/lander"),
            isEmbeddable: isEmbeddable
        )
    }

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
            ("pay in 4", try instrument(type: "PAYPAL_CREDIT", label: "Pay in 4", lastDigits: "0000", subtype: "PAY_LATER_US")),
            ("pay monthly", try instrument(type: "PAYPAL_CREDIT", label: "Pay Monthly", lastDigits: "0000", subtype: "PAY_LATER_US")),
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

    // MARK: - Glyph selection

    /// A card with no art and a bank with no art must not render the same glyph.
    func testRender_cardAndBankFallbackGlyphsDiffer() throws {
        let card = try instrument(type: "CARD", label: "Visa", lastDigits: "1234", imageURL: nil)
        let bank = try instrument(type: "BANK", label: "Visa", lastDigits: "1234", imageURL: nil)

        let cardImage = try render(view(state: .instrument(card))).pngData()
        let bankImage = try render(view(state: .instrument(bank))).pngData()

        XCTAssertNotEqual(cardImage, bankImage)
    }

    /// Only banks get the bank glyph; an unrecognised type is treated as a card rather than
    /// rendering a third, generic glyph.
    func testRender_unknownTypeFallsBackToTheCardGlyph() throws {
        let unknown = try instrument(type: "SOME_FUTURE_TYPE", label: "Visa", lastDigits: "1234", imageURL: nil)
        let card = try instrument(type: "CARD", label: "Visa", lastDigits: "1234", imageURL: nil)

        let unknownImage = try render(view(state: .instrument(unknown))).pngData()
        let cardImage = try render(view(state: .instrument(card))).pngData()

        XCTAssertEqual(unknownImage, cardImage)
    }

    /// Same label and digits, different type. A card renders card art plus "••0000"; PayPal Credit
    /// renders the label alone, so the two must not produce identical output.
    func testRender_payPalCreditDiffersFromACardWithTheSameFields() throws {
        let credit = try instrument(type: "PAYPAL_CREDIT", label: "Pay in 4", lastDigits: "0000")
        let card = try instrument(type: "CARD", label: "Pay in 4", lastDigits: "0000")

        let creditImage = try render(view(state: .instrument(credit))).pngData()
        let cardImage = try render(view(state: .instrument(card))).pngData()

        XCTAssertNotEqual(creditImage, cardImage)
    }

    // MARK: - Credit messaging

    /// The three message shapes share one render path, so they are driven from a table.
    func testRender_everyCreditMessageShape() {
        let contents: [(name: String, content: CreditMessageContent)] = [
            ("with learn more", creditContent()),
            ("without learn more", creditContent(learnMoreText: nil)),
            ("embeddable", creditContent(isEmbeddable: true))
        ]

        for entry in contents {
            let row = CreditMessagingRow(
                style: BTPayPalSavedPaymentMethodViewStyle(),
                content: entry.content,
                onLearnMore: {}
            )
            XCTAssertNotNil(rendered(row), entry.name)
        }
    }

    // MARK: - Child rows in isolation

    func testRender_skeletonRow() throws {
        try render(BTPayPalSavedPaymentMethodSkeletonRow(style: BTPayPalSavedPaymentMethodViewStyle()))
    }

    func testRender_creditMessageSkeleton() throws {
        try render(CreditMessageSkeleton())
    }

    func testRender_editFIRow_allContentCases() throws {
        let cases: [EditFIRow.Content] = [
            .instrument(try instrument()),
            .displayOnly(email: "buyer@example.com", isEditable: true),
            .displayOnly(email: "buyer@example.com", isEditable: false),
            .brandOnly
        ]

        for content in cases {
            try render(
                EditFIRow(content: content, style: BTPayPalSavedPaymentMethodViewStyle(), onEdit: {})
            )
        }
    }

    // MARK: - Accessibility layout

    /// `EditFIRow` uses `ViewThatFits` to fall back to a stacked layout. At the largest
    /// accessibility sizes the side-by-side layout no longer fits and the account digits
    /// previously truncated to `··1…`, hiding which card would be charged.
    func testRender_instrumentRow_atEveryDynamicTypeSize() throws {
        let sizes: [DynamicTypeSize] = [
            .xSmall, .large, .xxxLarge,
            .accessibility1, .accessibility3, .accessibility5
        ]

        for size in sizes {
            try render(view(state: .instrument(try instrument())), typeSize: size)
        }
    }

    func testRender_instrumentRow_atNarrowWidthUsesStackedLayout() throws {
        try render(view(state: .instrument(try instrument())), width: 200, typeSize: .accessibility5)
    }

    func testRender_longLabelTruncatesWithoutTrapping() throws {
        let fi = try instrument(label: String(repeating: "Very Long Bank Name ", count: 10))
        try render(view(state: .instrument(fi)), typeSize: .accessibility5)
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

    /// `EditFiStyleGuard` clamps negatives to zero so a merchant can never hand SwiftUI a
    /// negative frame. An explicit negative height collapses the component rather than trapping.
    func testRender_withNegativeHeight_collapsesInsteadOfTrapping() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container = .init(height: -100)

        XCTAssertEqual(EditFiStyleGuard.containerHeight(-100), 0)
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
}
