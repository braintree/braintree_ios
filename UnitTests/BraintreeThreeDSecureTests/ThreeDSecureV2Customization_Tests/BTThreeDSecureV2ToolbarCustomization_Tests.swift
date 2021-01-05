import XCTest
import CardinalMobile

class BTThreeDSecureV2ToolbarCustomization_Tests: XCTestCase {

    func testBTThreeDSecureV2ToolbarCustomization_setsAllCardinalClassProperties() {
        let toolbarCustomization = BTThreeDSecureV2ToolbarCustomization()
        toolbarCustomization.backgroundColor = "Blue"
        toolbarCustomization.headerText = "Rad Text"
        toolbarCustomization.buttonText = "Button"
        toolbarCustomization.textColor = "Red"
        toolbarCustomization.textFontSize = 12
        toolbarCustomization.textFontName = "Helvetica"

        let cardinalToolbar = toolbarCustomization.cardinalValue as! ToolbarCustomization
        XCTAssertEqual(cardinalToolbar.backgroundColor, "Blue")
        XCTAssertEqual(cardinalToolbar.headerText, "Rad Text")
        XCTAssertEqual(cardinalToolbar.buttonText, "Button")
        XCTAssertEqual(cardinalToolbar.textColor, "Red")
        XCTAssertEqual(cardinalToolbar.textFontSize, 12)
        XCTAssertEqual(cardinalToolbar.textFontName, "Helvetica")
    }

}
