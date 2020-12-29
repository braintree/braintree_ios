import XCTest
import CardinalMobile

class BTThreeDSecureV2ButtonCustomization_Tests: XCTestCase {

    func testBTThreeDSecureV2ButtonCustomization_setsAllCardinalClassProperties() {
        let buttonCustomization = BTThreeDSecureV2ButtonCustomization()
        buttonCustomization.backgroundColor = "Green"
        buttonCustomization.cornerRadius = 5
        buttonCustomization.textColor = "Red"
        buttonCustomization.textFontSize = 11
        buttonCustomization.textFontName = "Times New Roman"

        let cardinalButton = buttonCustomization.cardinalValue as! ButtonCustomization
        XCTAssertEqual(cardinalButton.backgroundColor, "Green")
        XCTAssertEqual(cardinalButton.cornerRadius, 5)
        XCTAssertEqual(cardinalButton.textColor, "Red")
        XCTAssertEqual(cardinalButton.textFontSize, 11)
        XCTAssertEqual(cardinalButton.textFontName, "Times New Roman")
    }

}
