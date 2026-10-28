import XCTest
import CardinalMobile
@testable import BraintreePaymentActions

class BTThreeDSecureLaunchUICustomization_Tests: XCTestCase {

    func testBTThreeDSecureLaunchUICustomization_setsAllCardinalClassProperties() {
        let uiCustomization = BTThreeDSecureLaunchUICustomization()
        uiCustomization.setButton(BTThreeDSecureLaunchButtonCustomization(), buttonType: .cancel)
        uiCustomization.labelCustomization = BTThreeDSecureLaunchLabelCustomization()
        uiCustomization.textBoxCustomization = BTThreeDSecureLaunchTextBoxCustomization()
        uiCustomization.toolbarCustomization = BTThreeDSecureLaunchToolbarCustomization()

        let cardinalUICustomization = uiCustomization.cardinalValue
        XCTAssertNotNil(cardinalUICustomization.getButtonCustomization(ButtonType(3)))
        XCTAssertNotNil(cardinalUICustomization.getLabel())
        XCTAssertNotNil(cardinalUICustomization.getTextBox())
        XCTAssertNotNil(cardinalUICustomization.getToolbarCustomization())
    }
}
