import XCTest
import CardinalMobile

class BTThreeDSecureV2LabelCustomization_Tests: XCTestCase {

    func testBTThreeDSecureV2LabelCustomization_setsAllCardinalClassProperties() {
        let labelCustomization = BTThreeDSecureV2LabelCustomization()
        labelCustomization.headingTextColor = "Silver"
        labelCustomization.headingTextFontName = "Comic Sans"
        labelCustomization.headingTextFontSize = 12
        labelCustomization.textColor = "Pink"
        labelCustomization.textFontSize = 19
        labelCustomization.textFontName = "Arial"

        let cardinalLabel = labelCustomization.cardinalValue as! LabelCustomization
        XCTAssertEqual(cardinalLabel.headingTextColor, "Silver")
        XCTAssertEqual(cardinalLabel.headingTextFontName, "Comic Sans")
        XCTAssertEqual(cardinalLabel.headingTextFontSize, 12)
        XCTAssertEqual(cardinalLabel.textColor, "Pink")
        XCTAssertEqual(cardinalLabel.textFontSize, 19)
        XCTAssertEqual(cardinalLabel.textFontName, "Arial")
    }

}
