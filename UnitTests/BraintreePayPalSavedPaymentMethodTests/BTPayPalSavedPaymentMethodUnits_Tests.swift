import SwiftUI
import XCTest
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodError_Tests: XCTestCase {

    private let allCases: [BTPayPalSavedPaymentMethodError] = [
        .invalidAuthorization,
        .missingPaymentMethodIDJWT,
        .missingOrderID,
        .emptyBodyReturned,
        .failedToParseSummary,
        .missingPreferredMessage
    ]

    /// The raw values are the wire contract for merchants switching on `errorCode`; reordering
    /// the enum would silently repoint every code.
    func testErrorCodes_matchDocumentedRawValues() {
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.invalidAuthorization.errorCode, 0)
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.missingPaymentMethodIDJWT.errorCode, 1)
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.missingOrderID.errorCode, 2)
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.emptyBodyReturned.errorCode, 3)
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.failedToParseSummary.errorCode, 4)
        XCTAssertEqual(BTPayPalSavedPaymentMethodError.missingPreferredMessage.errorCode, 5)
    }

    func testErrorDescription_everyCaseHasANonEmptyMessage() throws {
        for error in allCases {
            let description = try XCTUnwrap(
                error.errorDescription,
                "\(error) is missing an errorDescription"
            )
            XCTAssertFalse(description.isEmpty)
        }
    }

    func testErrorDescription_isUniquePerCase() {
        let descriptions = allCases.compactMap(\.errorDescription)
        XCTAssertEqual(Set(descriptions).count, allCases.count)
    }

    func testAsNSError_carriesDomainAndCode() {
        let nsError = BTPayPalSavedPaymentMethodError.missingOrderID as NSError

        XCTAssertEqual(nsError.domain, "com.braintreepayments.BTPayPalSavedPaymentMethodErrorDomain")
        XCTAssertEqual(nsError.code, 2)
    }
}

final class BTPayPalSavedPaymentMethodFont_Tests: XCTestCase {

    /// An empty string is treated as "no custom font" rather than being passed to
    /// `Font.custom`, which would resolve to an unpredictable fallback face.
    func testFont_withEmptyName_fallsBackToSystemFont() {
        XCTAssertEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "", size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14)
        )
    }

    func testFont_withCustomName_differsFromSystemFont() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "Georgia", size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14)
        )
    }

    func testFont_weightIsAppliedToCustomFonts() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: "HelveticaNeue", size: 14, weight: .bold),
            BTPayPalSavedPaymentMethodFont.font(name: "HelveticaNeue", size: 14, weight: .regular)
        )
    }

    func testFont_weightIsAppliedToSystemFonts() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, weight: .bold),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14, weight: .regular)
        )
    }

    func testFont_sizeChangesProduceDistinctFonts() {
        XCTAssertNotEqual(
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 20)
        )
    }
}

final class PayPalSavedPaymentMethodBundle_Tests: XCTestCase {

    /// The component's card-art and spinner assets are loaded from this bundle at render time,
    /// so a mis-resolved bundle surfaces as silently missing artwork rather than a build error.
    func testBundle_resolvesAndContainsComponentAssets() {
        let bundle = Bundle.payPalSavedPaymentMethod

        for asset in ["LoadingSpinner", "CardFundingIcon", "BankFundingIcon", "EditPencil", "PayPalBadge"] {
            XCTAssertNotNil(
                UIImage(named: asset, in: bundle, compatibleWith: nil),
                "\(asset) missing from \(bundle.bundlePath)"
            )
        }
    }

    /// Card and bank fall back to different glyphs, so a regression that collapsed them onto one
    /// asset would otherwise be invisible.
    func testFallbackGlyphs_areDistinctPerFundingInstrumentType() throws {
        let bundle = Bundle.payPalSavedPaymentMethod
        let card = try XCTUnwrap(UIImage(named: "CardFundingIcon", in: bundle, compatibleWith: nil)).pngData()
        let bank = try XCTUnwrap(UIImage(named: "BankFundingIcon", in: bundle, compatibleWith: nil)).pngData()

        XCTAssertNotEqual(card, bank)
    }
}

final class BTPayPalSavedPaymentMethodViewStyle_Tests: XCTestCase {

    /// These three are opt-out, not opt-in: a merchant who passes no style gets the full component.
    func testDefaultStyle_showsLogoLabelAndCreditMessaging() {
        let style = BTPayPalSavedPaymentMethodViewStyle()

        XCTAssertTrue(style.showPayPalLogo)
        XCTAssertTrue(style.showPayPalLabel)
        XCTAssertTrue(style.showPayPalCreditMessaging)
    }

    /// `nil` means "use the SDK defaults", so the guard resolves them rather than the style struct.
    func testDefaultStyle_leavesAppearanceAndContainerUnset() {
        let style = BTPayPalSavedPaymentMethodViewStyle()

        XCTAssertNil(style.componentAppearance)
        XCTAssertNil(style.container)
    }
}

final class CreditMessageContent_Tests: XCTestCase {

    private func result(actionItems: [[String: Any]]) throws -> BTPayPalCreditMessagingResult {
        try XCTUnwrap(
            BTPayPalCreditMessagingResult(
                json: BTJSON(
                    value: [
                        "messages": [
                            [
                                "preferred_message": [
                                    "content": [
                                        "main_items": [["type": "TEXT", "text": "Or 4 interest-free payments."]],
                                        "action_items": actionItems
                                    ]
                                ]
                            ]
                        ]
                    ] as [String: Any]
                )
            )
        )
    }

    func testInit_whenTheActionItemHasAClickURL_keepsTheLearnMoreCopy() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [
                ["type": "LINK", "text": "Learn more", "click_url": "https://example.com/click"]
            ])
        )

        XCTAssertEqual(content?.learnMoreText, "Learn more")
        XCTAssertEqual(content?.learnMoreURL, URL(string: "https://example.com/click"))
    }

    /// Copy without a URL would render a link that does nothing when tapped, so it is dropped.
    func testInit_whenTheActionItemHasNoClickURL_dropsTheLearnMoreCopy() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [["type": "LINK", "text": "Learn more"]])
        )

        XCTAssertNil(content?.learnMoreText)
        XCTAssertNil(content?.learnMoreURL)
        XCTAssertEqual(content?.message, "Or 4 interest-free payments.")
    }
}
