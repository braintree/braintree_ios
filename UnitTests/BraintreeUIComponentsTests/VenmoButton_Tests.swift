import XCTest
import SwiftUI
@testable import BraintreeUIComponents
@testable import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

final class VenmoButton_Tests: XCTestCase {

    private let tokenizationKey = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://www.example.com")!

    private func makeButton() -> VenmoButton {
        VenmoButton(
            authorization: tokenizationKey,
            universalLink: universalLink,
            request: BTVenmoRequest(paymentMethodUsage: .singleUse),
            completion: { _, _ in }
        )
    }

    // MARK: - Analytics

    func testDidAppear_sendsPresentedAnalyticsEvent() {
        var button = makeButton()
        let mockAPIClient = MockAPIClient(authorization: tokenizationKey)
        button.apiClient = mockAPIClient

        button.didAppear()

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.venmoButtonPresented))
    }

    func testDidSelectButton_sendsSelectedAnalyticsEvent() {
        var button = makeButton()
        let mockAPIClient = MockAPIClient(authorization: tokenizationKey)
        button.apiClient = mockAPIClient

        button.didSelectButton()

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.venmoButtonSelected))
    }

    // MARK: - Color

    func testVenmoButtonColor_blue_hasCorrectProperties() {
        let color = VenmoButtonColor.blue

        XCTAssertEqual(color.backgroundColor, Color(hex: "#008CFF"))
        XCTAssertEqual(color.logoImageName, "VenmoLogoWhite")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#0074FF"))
        XCTAssertEqual(color.spinnerColor, "SpinnerWhite")
    }

    func testVenmoButtonColor_black_hasCorrectProperties() {
        let color = VenmoButtonColor.black

        XCTAssertEqual(color.backgroundColor, .black)
        XCTAssertEqual(color.logoImageName, "VenmoLogoWhite")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#696969"))
        XCTAssertEqual(color.spinnerColor, "SpinnerWhite")
    }

    func testVenmoButtonColor_white_hasCorrectProperties() {
        let color = VenmoButtonColor.white

        XCTAssertEqual(color.backgroundColor, .white)
        XCTAssertEqual(color.logoImageName, "VenmoLogoBlue")
        XCTAssertTrue(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#E9E9E9"))
        XCTAssertEqual(color.spinnerColor, "SpinnerBlue")
    }
}
