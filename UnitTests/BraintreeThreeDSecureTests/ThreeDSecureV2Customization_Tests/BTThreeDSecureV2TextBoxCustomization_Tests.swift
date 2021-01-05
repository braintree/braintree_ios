import XCTest
import CardinalMobile

class BTThreeDSecureV2TextBoxCustomization_Tests: XCTestCase {

    func testBTThreeDSecureV2TextBoxCustomization_setsAllCardinalClassProperties() {
        let textBoxCustomization = BTThreeDSecureV2TextBoxCustomization()
        textBoxCustomization.borderColor = "Orange"
        textBoxCustomization.borderWidth = 1
        textBoxCustomization.cornerRadius = 7
        textBoxCustomization.textColor = "Red"
        textBoxCustomization.textFontSize = 5
        textBoxCustomization.textFontName = "Arial"

        let cardinalTextBox = textBoxCustomization.cardinalValue as! TextBoxCustomization
        XCTAssertEqual(cardinalTextBox.borderColor, "Orange")
        XCTAssertEqual(cardinalTextBox.borderWidth, 1)
        XCTAssertEqual(cardinalTextBox.cornerRadius, 7)
        XCTAssertEqual(cardinalTextBox.textColor, "Red")
        XCTAssertEqual(cardinalTextBox.textFontSize, 5)
        XCTAssertEqual(cardinalTextBox.textFontName, "Arial")

    }

}
