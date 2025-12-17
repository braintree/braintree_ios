import XCTest
import SwiftUI
@testable import BraintreeUIComponents

final class VenmoButton_Tests: XCTestCase {

    func testVenmoButtonColor_blue_hasCorrectProperties() {
        let color = VenmoButtonColor.blue

        XCTAssertEqual(color.backgroundColor, Color(hex: "#008CFF"))
        XCTAssertEqual(color.logoImageName, "VenmoLogoWhite")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#0074FF"))
    }

    func testVenmoButtonColor_black_hasCorrectProperties() {
        let color = VenmoButtonColor.black

        XCTAssertEqual(color.backgroundColor, .black)
        XCTAssertEqual(color.logoImageName, "VenmoLogoWhite")
        XCTAssertFalse(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#696969"))
    }

    func testVenmoButtonColor_white_hasCorrectProperties() {
        let color = VenmoButtonColor.white

        XCTAssertEqual(color.backgroundColor, .white)
        XCTAssertEqual(color.logoImageName, "VenmoLogoBlue")
        XCTAssertTrue(color.hasOutline)
        XCTAssertEqual(color.tappedButtonColor, Color(hex: "#E9E9E9"))
    }
}
