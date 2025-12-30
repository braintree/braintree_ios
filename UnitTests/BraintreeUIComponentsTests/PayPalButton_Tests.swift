import XCTest
import SwiftUI
@testable import BraintreeUIComponents

final class PayPalButton_Tests: XCTestCase {

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
