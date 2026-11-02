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
        XCTAssertNotNil(cardinalUICustomization.getButtonCustomization(ButtonTypeCancel))
        XCTAssertNotNil(cardinalUICustomization.getLabel())
        XCTAssertNotNil(cardinalUICustomization.getTextBox())
        XCTAssertNotNil(cardinalUICustomization.getToolbarCustomization())
    }

    // MARK: - BTThreeDSecureLaunchButtonType.cardinalValue

    func testCardinalValue_mapsEveryCaseByNameNotRawValue() {
        XCTAssertEqual(BTThreeDSecureLaunchButtonType.verify.cardinalValue, ButtonTypeVerify)
        XCTAssertEqual(BTThreeDSecureLaunchButtonType.continue.cardinalValue, ButtonTypeContinue)
        XCTAssertEqual(BTThreeDSecureLaunchButtonType.next.cardinalValue, ButtonTypeNext)
        XCTAssertEqual(BTThreeDSecureLaunchButtonType.cancel.cardinalValue, ButtonTypeCancel)
        XCTAssertEqual(BTThreeDSecureLaunchButtonType.resend.cardinalValue, ButtonTypeResend)
    }
}
