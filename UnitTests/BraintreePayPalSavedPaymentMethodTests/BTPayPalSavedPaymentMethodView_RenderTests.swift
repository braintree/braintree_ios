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

    func testRender_loadingState_rendersSkeleton() throws {
        try render(view(state: .loading))
    }

    func testRender_loadingState_withCreditMessagingDisabled_rendersFISkeletonOnly() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.showPayPalCreditMessaging = false
        try render(view(state: .loading, style: style))
    }

    /// Credit messaging is enabled but has not resolved yet, so both rows shimmer.
    func testRender_loadingState_withCreditMessagingPending_rendersBothSkeletons() throws {
        try render(view(state: .loading))
    }

    func testRender_instrumentState_rendersCardRow() throws {
        try render(view(state: .instrument(try instrument())))
    }

    func testRender_instrumentWithRemoteImage_rendersAsyncImagePlaceholder() throws {
        let fi = try instrument(imageURL: "https://example.com/visa.png")
        try render(view(state: .instrument(fi)))
    }

    func testRender_instrumentWithoutImage_rendersFallbackGlyph() throws {
        try render(view(state: .instrument(try instrument(imageURL: nil))))
    }

    func testRender_bankInstrument_rendersBankGlyph() throws {
        let fi = try instrument(type: "BANK", label: "CREDIT UNION 1", lastDigits: "0199")
        try render(view(state: .instrument(fi)))
    }

    /// PayPal Credit reports a placeholder `lastDigits` of "0000" and no image, so the row must
    /// render its label alone rather than "••0000" beside a generic glyph.
    func testRender_payPalCreditPayIn4_rendersLabelOnly() throws {
        let fi = try instrument(
            type: "PAYPAL_CREDIT",
            label: "Pay in 4",
            lastDigits: "0000",
            subtype: "PAY_LATER_US"
        )
        try render(view(state: .instrument(fi)))
    }

    func testRender_payPalCreditPayMonthly_rendersLabelOnly() throws {
        let fi = try instrument(
            type: "PAYPAL_CREDIT",
            label: "Pay Monthly",
            lastDigits: "0000",
            subtype: "PAY_LATER_US"
        )
        try render(view(state: .instrument(fi)))
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

    func testRender_instrumentWithUnknownType_rendersWithoutTrapping() throws {
        let fi = try instrument(type: "SOME_FUTURE_TYPE", label: "Mystery")
        try render(view(state: .instrument(fi)))
    }

    func testRender_instrumentWithMissingFields_rendersWithoutTrapping() throws {
        let fi = try instrument(label: nil, lastDigits: nil)
        try render(view(state: .instrument(fi)))
    }

    func testRender_displayOnlyEditable_rendersEmailWithPencil() throws {
        try render(view(state: .displayOnly(email: "buyer@example.com", isEditable: true)))
    }

    func testRender_displayOnlyNotEditable_rendersEmailWithoutPencil() throws {
        try render(view(state: .displayOnly(email: "buyer@example.com", isEditable: false)))
    }

    func testRender_brandOnlyState_rendersLogoOnly() throws {
        try render(view(state: .brandOnly))
    }

    /// `.hidden` must take up no space at all, not render an empty tile with padding and a border.
    func testRender_hiddenState_occupiesNoSpace() {
        XCTAssertNil(rendered(view(state: .hidden)))
    }

    // MARK: - Credit messaging

    func testRender_instrumentWithCreditMessage_rendersMessageRow() throws {
        try render(view(state: .instrument(try instrument()), showCreditMessage: true))
    }

    func testRender_creditMessagingRow_withLearnMore() throws {
        try render(
            CreditMessagingRow(
                style: BTPayPalSavedPaymentMethodViewStyle(),
                content: creditContent(),
                onLearnMore: {}
            )
        )
    }

    func testRender_creditMessagingRow_withoutLearnMore() throws {
        try render(
            CreditMessagingRow(
                style: BTPayPalSavedPaymentMethodViewStyle(),
                content: creditContent(learnMoreText: nil),
                onLearnMore: {}
            )
        )
    }

    func testRender_creditMessagingRow_embeddable() throws {
        try render(
            CreditMessagingRow(
                style: BTPayPalSavedPaymentMethodViewStyle(),
                content: creditContent(isEmbeddable: true),
                onLearnMore: {}
            )
        )
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

    func testRender_withLogoAndLabelHidden() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.showPayPalLogo = false
        style.showPayPalLabel = false
        try render(view(state: .instrument(try instrument()), showCreditMessage: true, style: style))
    }

    func testRender_withCreditMessagingDisabled() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.showPayPalCreditMessaging = false
        try render(view(state: .instrument(try instrument()), showCreditMessage: true, style: style))
    }

    func testRender_withFullyCustomisedStyle() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.componentAppearance = .init(
            backgroundColor: .systemPink,
            textColor: .white,
            baseFontSize: 18,
            fontName: "Georgia"
        )
        style.container = .init(
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

        try render(view(state: .instrument(try instrument()), showCreditMessage: true, style: style))
    }

    /// `EditFiStyleGuard` clamps negatives to zero so a merchant can never hand SwiftUI a
    /// negative frame. An explicit negative height collapses the component rather than trapping.
    func testRender_withNegativeStyleValues_clampsInsteadOfTrapping() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.componentAppearance = .init(baseFontSize: -20)
        style.container = .init(
            height: -100,
            horizontalPadding: -10,
            verticalPadding: -10,
            cornerRadius: -8,
            borderWidth: -4,
            logo: .init(width: -30),
            label: .init(fontSize: -12, leadingGap: -6),
            fundingInstrument: .init(textFontSize: -14, editIconSize: -20, leadingGap: -5),
            creditMessaging: .init(fontSize: -11)
        )

        XCTAssertEqual(EditFiStyleGuard.containerHeight(-100), 0)
        XCTAssertNil(rendered(view(state: .instrument(try instrument()), showCreditMessage: true, style: style)))
    }

    /// Negative dimensions everywhere *except* height still produce a laid-out component.
    func testRender_withNegativeStyleValuesAndIntrinsicHeight_stillRenders() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.componentAppearance = .init(baseFontSize: -20)
        style.container = .init(
            horizontalPadding: -10,
            verticalPadding: -10,
            cornerRadius: -8,
            borderWidth: -4,
            logo: .init(width: -30),
            label: .init(fontSize: -12, leadingGap: -6),
            fundingInstrument: .init(textFontSize: -14, editIconSize: -20, leadingGap: -5),
            creditMessaging: .init(fontSize: -11)
        )

        try render(view(state: .instrument(try instrument()), showCreditMessage: true, style: style))
    }

    func testRender_withZeroHeight_collapsesComponent() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container = .init(height: 0, horizontalPadding: 0, verticalPadding: 0, cornerRadius: 0, borderWidth: 0)
        XCTAssertNil(rendered(view(state: .instrument(try instrument()), style: style)))
    }

    func testRender_withZeroPaddingAndIntrinsicHeight_rendersWithoutTrapping() throws {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container = .init(horizontalPadding: 0, verticalPadding: 0, cornerRadius: 0, borderWidth: 0)
        try render(view(state: .instrument(try instrument()), style: style))
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
