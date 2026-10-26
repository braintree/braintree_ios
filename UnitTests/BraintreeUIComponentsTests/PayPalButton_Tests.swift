import XCTest
import SwiftUI
@testable import BraintreeUIComponents
@testable import BraintreePayPal
@testable import BraintreeCore
@testable import BraintreeTestShared

final class PayPalButton_Tests: XCTestCase {

    private let tokenizationKey = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://www.example.com/paypal")!

    private func makeButton() -> PayPalButton {
        PayPalButton(
            authorization: tokenizationKey,
            universalLink: universalLink,
            request: BTPayPalCheckoutRequest(amount: "10"),
            completion: { _, _ in }
        )
    }

    // MARK: - Analytics

    func testDidAppear_sendsPresentedAnalyticsEvent() {
        var button = makeButton()
        let mockAPIClient = MockAPIClient(authorization: tokenizationKey)
        button.apiClient = mockAPIClient

        button.didAppear()

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.payPalButtonPresented))
    }

    func testDidSelectButton_sendsSelectedAnalyticsEvent() {
        var button = makeButton()
        let mockAPIClient = MockAPIClient(authorization: tokenizationKey)
        button.apiClient = mockAPIClient

        button.didSelectButton()

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.payPalButtonSelected))
    }

    // MARK: - Color

    func testPayPalButtonColor_blue_hasCorrectProperties() {
        let color = PayPalButtonColor.blue

        XCTAssertEqual(color.backgroundColor, Color(hex: "#60CDFF"))
        XCTAssertEqual(color.logoImageName, "PayPalLogoBlack")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#3DB5FF"))
        XCTAssertEqual(color.spinnerColor, "SpinnerBlack")
    }

    func testPayPalButtonColor_black_hasCorrectProperties() {
        let color = PayPalButtonColor.black

        XCTAssertEqual(color.backgroundColor, .black)
        XCTAssertEqual(color.logoImageName, "PayPalLogoWhite")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#696969"))
        XCTAssertEqual(color.spinnerColor, "SpinnerWhite")
    }

    func testPayPalButtonColor_white_hasCorrectProperties() {
        let color = PayPalButtonColor.white

        XCTAssertEqual(color.backgroundColor, .white)
        XCTAssertEqual(color.logoImageName, "PayPalLogoBlack")
        XCTAssertTrue(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#E9E9E9"))
        XCTAssertEqual(color.spinnerColor, "SpinnerBlack")
    }
}
