import XCTest
import CardinalMobile

class BTThreeDSecureV2UICustomization_Tests: XCTestCase {

    func testBTThreeDSecureV2UICustomization_setsAllCardinalClassProperties() {
        let uiCustomization = BTThreeDSecureV2UICustomization()
        uiCustomization.setButton(BTThreeDSecureV2ButtonCustomization(), buttonType: .ButtonTypeCancel)
        uiCustomization.labelCustomization = BTThreeDSecureV2LabelCustomization()
        uiCustomization.textBoxCustomization = BTThreeDSecureV2TextBoxCustomization()
        uiCustomization.toolbarCustomization = BTThreeDSecureV2ToolbarCustomization()

        let cardinalUICustomization = uiCustomization.cardinalValue!
        XCTAssertNotNil(cardinalUICustomization.getButtonCustomization(ButtonType(3)))
        XCTAssertNotNil(cardinalUICustomization.getLabel())
        XCTAssertNotNil(cardinalUICustomization.getTextBox())
        XCTAssertNotNil(cardinalUICustomization.getToolbarCustomization())
    }

}
