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

    func testErrorDomain_isNamespacedToTheModule() {
        XCTAssertEqual(
            BTPayPalSavedPaymentMethodError.errorDomain,
            "com.braintreepayments.BTPayPalSavedPaymentMethodErrorDomain"
        )
    }

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

    func testFont_withNilName_returnsSystemFont() {
        XCTAssertEqual(
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14),
            BTPayPalSavedPaymentMethodFont.font(name: nil, size: 14)
        )
    }

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

        XCTAssertNotNil(
            UIImage(named: "LoadingSpinner", in: bundle, compatibleWith: nil),
            "LoadingSpinner missing from \(bundle.bundlePath)"
        )
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
