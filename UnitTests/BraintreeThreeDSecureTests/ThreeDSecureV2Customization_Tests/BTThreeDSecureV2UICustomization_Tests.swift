import XCTest
import CardinalMobile

class BTThreeDSecureV2UICustomization_Tests: XCTestCase {

    func testSetsAToolbarIsActuallyCardinalToolbar() {
        let toolbarCustomization = BTThreeDSecureV2ToolbarCustomization()
        toolbarCustomization.backgroundColor = "Blue"
        toolbarCustomization.headerText = "Rad Text"
        toolbarCustomization.buttonText = "Button"
        toolbarCustomization.textColor = "Red"
        toolbarCustomization.textFontSize = 12
        toolbarCustomization.textFontName = "Helvetica"

        let uiCustomization = BTThreeDSecureV2UICustomization()
//        uiCustomization.toolbar
    }

}
