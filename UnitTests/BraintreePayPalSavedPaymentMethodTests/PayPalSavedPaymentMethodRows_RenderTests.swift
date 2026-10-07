import SwiftUI
import XCTest
@testable import BraintreePayPalSavedPaymentMethod

/// Renders each row on its own. The accessibility truncation bug this suite guards against lived
/// entirely inside `EditFIRow`'s layout, where no view model assertion could see it.
final class PayPalSavedPaymentMethodRows_RenderTests: SavedPaymentMethodRenderTestCase {

    // MARK: - Helpers

    private func row(_ content: EditFIRow.Content) -> EditFIRow {
        EditFIRow(content: content, style: PayPalSavedPaymentMethodViewStyle(), onEdit: {})
    }

    // MARK: - Glyph selection

    /// A card with no art and a bank with no art must not render the same glyph.
    func testRender_cardAndBankFallbackGlyphsDiffer() throws {
        let card = try instrument(type: "CARD", label: "Visa", lastDigits: "1234", imageURL: nil)
        let bank = try instrument(type: "BANK", label: "Visa", lastDigits: "1234", imageURL: nil)

        let cardImage = try render(row(.instrument(card))).pngData()
        let bankImage = try render(row(.instrument(bank))).pngData()

        XCTAssertNotEqual(cardImage, bankImage)
    }

    /// Only banks get the bank glyph; an unrecognised type is treated as a card rather than
    /// rendering a third, generic glyph.
    func testRender_unknownTypeFallsBackToTheCardGlyph() throws {
        let unknown = try instrument(type: "SOME_FUTURE_TYPE", label: "Visa", lastDigits: "1234", imageURL: nil)
        let card = try instrument(type: "CARD", label: "Visa", lastDigits: "1234", imageURL: nil)

        let unknownImage = try render(row(.instrument(unknown))).pngData()
        let cardImage = try render(row(.instrument(card))).pngData()

        XCTAssertEqual(unknownImage, cardImage)
    }

    /// Same label and digits, different type. A card renders card art plus its last digits; PayPal
    /// Credit renders the label alone, so the two must not produce identical output.
    func testRender_payPalCreditDiffersFromACardWithTheSameFields() throws {
        let credit = try instrument(type: "PAYPAL_CREDIT", label: "PayPal Credit", lastDigits: "1234")
        let card = try instrument(type: "CARD", label: "PayPal Credit", lastDigits: "1234")

        let creditImage = try render(row(.instrument(credit))).pngData()
        let cardImage = try render(row(.instrument(card))).pngData()

        XCTAssertNotEqual(creditImage, cardImage)
    }

    // MARK: - Credit messaging

    private func creditRow(learnMoreText: String? = "Learn more", linkColor: UIColor? = nil) -> CreditMessagingRow {
        CreditMessagingRow(
            style: PayPalSavedPaymentMethodViewStyle(
                container: .init(creditMessaging: .init(linkColor: linkColor))
            ),
            message: "Or 4 interest-free payments of $324.50.",
            learnMoreText: learnMoreText,
            learnMoreURL: URL(string: "https://example.com/lander"),
            onLearnMore: {}
        )
    }

    func testAttributedMessage_withLearnMore_linksTheURLAndUnderlinesWithoutALinkColor() throws {
        let message = creditRow().attributedMessage
        let link = try XCTUnwrap(message.runs.first { $0.link != nil })

        XCTAssertEqual(String(message[link.range].characters), "Learn more")
        XCTAssertEqual(link.link, URL(string: "https://example.com/lander"))
        XCTAssertEqual(link.underlineStyle, .single)
    }

    func testAttributedMessage_withALinkColor_doesNotUnderline() throws {
        let message = creditRow(linkColor: .systemBlue).attributedMessage
        let link = try XCTUnwrap(message.runs.first { $0.link != nil })

        XCTAssertNil(link.underlineStyle)
    }

    func testAttributedMessage_withoutLearnMoreText_hasNoLink() {
        let message = creditRow(learnMoreText: nil).attributedMessage

        XCTAssertEqual(String(message.characters), "Or 4 interest-free payments of $324.50.")
        XCTAssertFalse(message.runs.contains { $0.link != nil })
    }

    // MARK: - Child rows in isolation

    func testRender_editFIRow_allContentCases() throws {
        let cases: [EditFIRow.Content] = [
            .instrument(try instrument()),
            .displayOnly(email: "buyer@example.com", isEditable: true),
            .displayOnly(email: "buyer@example.com", isEditable: false),
            .brandOnly
        ]

        for content in cases {
            try render(
                EditFIRow(content: content, style: PayPalSavedPaymentMethodViewStyle(), onEdit: {})
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
            try render(row(.instrument(try instrument())), typeSize: size)
        }
    }

    func testRender_instrumentRow_atNarrowWidthUsesStackedLayout() throws {
        try render(row(.instrument(try instrument())), width: 200, typeSize: .accessibility5)
    }

    func testRender_longLabelTruncatesWithoutTrapping() throws {
        let fi = try instrument(label: String(repeating: "Very Long Bank Name ", count: 10))
        try render(row(.instrument(fi)), typeSize: .accessibility5)
    }
}
