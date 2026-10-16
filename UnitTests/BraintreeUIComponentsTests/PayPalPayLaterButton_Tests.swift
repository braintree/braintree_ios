import XCTest
import SwiftUI
@testable import BraintreeUIComponents
@_spi(BraintreeUIComponents) @testable import BraintreePayPal
@testable import BraintreeCore

final class PayPalPayLaterButton_Tests: XCTestCase {

    private let tokenizationKey = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://www.example.com/paypal")!

    private func makeButton(
        request: BTPayPalCheckoutRequest = BTPayPalCheckoutRequest(amount: "10"),
        fallbackURLScheme: String? = nil,
        color: PayPalPayLaterButtonColor? = .blue,
        width: CGFloat? = 300
    ) -> PayPalPayLaterButton {
        PayPalPayLaterButton(
            authorization: tokenizationKey,
            universalLink: universalLink,
            fallbackURLScheme: fallbackURLScheme,
            request: request,
            color: color,
            width: width,
            completion: { _, _ in }
        )
    }

    // MARK: - Constants

    func testWidthConstants_matchDocumentedLimits() {
        XCTAssertEqual(PayPalPayLaterButton.minimumWidth, 158)
        XCTAssertEqual(PayPalPayLaterButton.maximumWidth, 300)
    }

    // MARK: - Initializer

    func testInit_setsOfferPayLaterToTrueOnRequest() {
        let request = BTPayPalCheckoutRequest(amount: "10")
        XCTAssertFalse(request.offerPayLater)

        _ = makeButton(request: request)

        XCTAssertTrue(request.offerPayLater)
    }

    func testInit_storesProvidedValues() {
        let request = BTPayPalCheckoutRequest(amount: "25.00")
        let button = makeButton(
            request: request,
            fallbackURLScheme: "com.my-app.payments",
            color: .black,
            width: 200
        )

        XCTAssertEqual(button.authorization, tokenizationKey)
        XCTAssertEqual(button.universalLink, universalLink)
        XCTAssertEqual(button.fallbackURLScheme, "com.my-app.payments")
        XCTAssertTrue(button.checkoutRequest === request)
        XCTAssertEqual(button.color, .black)
        XCTAssertEqual(button.width, 200)
    }

    func testInit_defaultsColorToBlueWidthTo300AndNoFallbackScheme() {
        let button = PayPalPayLaterButton(
            authorization: tokenizationKey,
            universalLink: universalLink,
            request: BTPayPalCheckoutRequest(amount: "10"),
            completion: { _, _ in }
        )

        XCTAssertEqual(button.color, .blue)
        XCTAssertEqual(button.width, 300)
        XCTAssertNil(button.fallbackURLScheme)
    }

    // MARK: - Body

    func testBody_rendersForAllColorsAndWidths() {
        let colors: [PayPalPayLaterButtonColor?] = [.blue, .black, .white, nil]
        let widths: [CGFloat?] = [nil, 100, 200, 350]

        for color in colors {
            for width in widths {
                let button = makeButton(color: color, width: width)
                _ = button.body
            }
        }
    }

    // MARK: - PayPalPayLaterButtonColor

    func testColor_logoImageName() {
        XCTAssertEqual(PayPalPayLaterButtonColor.blue.logoImageName, "PayLaterLogoBlack")
        XCTAssertEqual(PayPalPayLaterButtonColor.black.logoImageName, "PayLaterLogoWhite")
        XCTAssertEqual(PayPalPayLaterButtonColor.white.logoImageName, "PayLaterLogoBlack")
    }

    func testColor_backgroundColor_matchesPayPalButtonColor() {
        XCTAssertEqual(PayPalPayLaterButtonColor.blue.backgroundColor, PayPalButtonColor.blue.backgroundColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.black.backgroundColor, PayPalButtonColor.black.backgroundColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.white.backgroundColor, PayPalButtonColor.white.backgroundColor)
    }

    func testColor_hasOutline_matchesPayPalButtonColor() {
        XCTAssertEqual(PayPalPayLaterButtonColor.blue.hasOutline, PayPalButtonColor.blue.hasOutline)
        XCTAssertEqual(PayPalPayLaterButtonColor.black.hasOutline, PayPalButtonColor.black.hasOutline)
        XCTAssertEqual(PayPalPayLaterButtonColor.white.hasOutline, PayPalButtonColor.white.hasOutline)
    }

    func testColor_tappedButtonColor_matchesPayPalButtonColor() {
        XCTAssertEqual(PayPalPayLaterButtonColor.blue.tappedButtonColor, PayPalButtonColor.blue.tappedButtonColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.black.tappedButtonColor, PayPalButtonColor.black.tappedButtonColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.white.tappedButtonColor, PayPalButtonColor.white.tappedButtonColor)
    }

    func testColor_spinnerColor_matchesPayPalButtonColor() {
        XCTAssertEqual(PayPalPayLaterButtonColor.blue.spinnerColor, PayPalButtonColor.blue.spinnerColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.black.spinnerColor, PayPalButtonColor.black.spinnerColor)
        XCTAssertEqual(PayPalPayLaterButtonColor.white.spinnerColor, PayPalButtonColor.white.spinnerColor)
    }
}
