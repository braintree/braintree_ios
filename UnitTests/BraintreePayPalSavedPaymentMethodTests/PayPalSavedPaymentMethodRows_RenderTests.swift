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

    /// Same label and digits, different type. A card renders card art plus its last digits; PayPal
    /// Credit renders the label alone, so the two must not produce identical output.
    func testRender_payPalCreditDiffersFromACardWithTheSameFields() throws {
        let credit = try instrument(type: "PAYPAL_CREDIT", label: "PayPal Credit", lastDigits: "1234")
        let card = try instrument(type: "CARD", label: "PayPal Credit", lastDigits: "1234")

        let creditImage = try render(row(.instrument(credit))).pngData()
        let cardImage = try render(row(.instrument(card))).pngData()

        XCTAssertNotEqual(creditImage, cardImage)
    }

    // MARK: - FI text and glyph

    /// Only a regular card or bank shows its digits; every PayPal product and any type this SDK version
    /// doesn't know shows its label, and gets no generic glyph when PayPal sends no art.
    func testFIText_andFallbackGlyph_dependOnWhetherItIsARegularCardOrBank() throws {
        let cases: [(name: String, fi: PayPalSavedPaymentMethod, text: String, glyph: String?)] = [
            ("card", try instrument(type: "CARD", label: "Visa", lastDigits: "3339"), "••3339", "CardFundingIcon"),
            ("bank", try instrument(type: "BANK", label: "Chase", lastDigits: "0199"), "••0199", "BankFundingIcon"),
            ("card without digits", try instrument(type: "CARD", label: "Visa", lastDigits: nil), "Visa", nil),
            ("PayPal Debit", try instrument(type: "PPDC", label: "PayPal Debit", lastDigits: "1234"), "PayPal Debit", nil),
            (
                "PayPal Credit",
                try instrument(type: "PAYPAL_CREDIT", label: "PayPal Credit", lastDigits: "2687", subtype: "PPC_US_V2"),
                "PayPal Credit",
                nil
            ),
            (
                "Pay Monthly",
                try instrument(type: "PAYPAL_CREDIT", label: "Pay Monthly", lastDigits: "0000", subtype: "PAY_LATER_LONG_TERM_US"),
                "Pay Monthly",
                nil
            ),
            (
                "Pay in 4",
                try instrument(type: "PAYPAL_CREDIT", label: "Pay in 4", lastDigits: "0000", subtype: "PAY_LATER_US"),
                "Pay in 4",
                nil
            ),
            ("PayPal balance", try instrument(type: "BALANCE", label: "PayPal balance", lastDigits: nil), "PayPal balance", nil)
        ]

        for entry in cases {
            let row = row(.instrument(entry.fi))
            XCTAssertEqual(row.fiText(for: entry.fi), entry.text, entry.name)
            XCTAssertEqual(row.fallbackGlyphName(for: entry.fi), entry.glyph, entry.name)
        }
    }

    // MARK: - Accessibility label

    /// VoiceOver must read the digits one by one, and PayPal products by their label alone.
    func testFIAccessibilityLabel_readsDigitsIndividuallyAndCreditByLabel() throws {
        let cases: [(fi: PayPalSavedPaymentMethod, expected: String)] = [
            (try instrument(type: "CARD", label: "Visa", lastDigits: "1234"), "Visa, ending in 1 2 3 4"),
            (try instrument(type: "BANK", label: "Chase", lastDigits: "0199"), "Chase, ending in 0 1 9 9"),
            (try instrument(type: "PAYPAL_CREDIT", label: "PayPal Credit", lastDigits: "1234"), "PayPal Credit"),
            (try instrument(type: "PPDC", label: "PayPal Debit", lastDigits: "1234"), "PayPal Debit"),
            (try instrument(type: "CARD", label: "Visa", lastDigits: nil), "Visa"),
            (try instrument(type: "CARD", label: nil, lastDigits: "1234"), "ending in 1 2 3 4"),
            (try instrument(type: "CARD", label: "", lastDigits: "1234"), "ending in 1 2 3 4"),
            (try instrument(type: "PPDC", label: nil, lastDigits: nil), "Saved payment method")
        ]

        for (fi, expected) in cases {
            XCTAssertEqual(row(.instrument(fi)).fiAccessibilityLabel(for: fi), expected)
        }
    }

    /// With the brand mark hidden, the pill is the only thing VoiceOver reads, so it names PayPal itself.
    func testFIAccessibilityLabel_whenTheBrandMarkIsHidden_namesPayPal() throws {
        let fi = try instrument(type: "CARD", label: "Visa", lastDigits: "1234")
        let style = PayPalSavedPaymentMethodViewStyle(showPayPalLogo: false, showPayPalLabel: false)
        let row = EditFIRow(content: .instrument(fi), style: style, onEdit: {})

        XCTAssertEqual(row.fiAccessibilityLabel(for: fi), "PayPal, Visa, ending in 1 2 3 4")
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
        for text in [nil, ""] {
            let message = creditRow(learnMoreText: text).attributedMessage

            XCTAssertEqual(String(message.characters), "Or 4 interest-free payments of $324.50.")
            XCTAssertFalse(message.runs.contains { $0.link != nil })
        }
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

    /// Brand-only has no pill, so the stacked layout must not add its row spacing below the brand mark.
    func testRender_brandOnlyRow_whenStacked_isNoTallerThanTheBrandMark() throws {
        let style = PayPalSavedPaymentMethodViewStyle()
        let row = try render(row(.brandOnly), width: 60, typeSize: .accessibility5)
        let brandMark = try render(PayPalBrandCluster(style: style), width: 60, typeSize: .accessibility5)

        XCTAssertEqual(row.size.height, brandMark.size.height)
    }

    func testRender_longLabelTruncatesWithoutTrapping() throws {
        let fi = try instrument(label: String(repeating: "Very Long Bank Name ", count: 10))
        try render(row(.instrument(fi)), typeSize: .accessibility5)
    }
}
