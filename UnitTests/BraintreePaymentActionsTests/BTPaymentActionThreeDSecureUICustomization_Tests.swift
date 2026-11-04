import XCTest
import CardinalMobile
@testable import BraintreePaymentActions

class BTPaymentActionThreeDSecureUICustomization_Tests: XCTestCase {

    func testBTPaymentActionThreeDSecureUICustomization_setsAllCardinalClassProperties() {
        let uiCustomization = BTPaymentActionThreeDSecureUICustomization()
        uiCustomization.setButton(BTPaymentActionThreeDSecureButtonCustomization(), buttonType: .cancel)
        uiCustomization.labelCustomization = BTPaymentActionThreeDSecureLabelCustomization()
        uiCustomization.textBoxCustomization = BTPaymentActionThreeDSecureTextBoxCustomization()
        uiCustomization.toolbarCustomization = BTPaymentActionThreeDSecureToolbarCustomization()

        let cardinalUICustomization = uiCustomization.cardinalValue
        XCTAssertNotNil(cardinalUICustomization.getButtonCustomization(ButtonTypeCancel))
        XCTAssertNotNil(cardinalUICustomization.getLabel())
        XCTAssertNotNil(cardinalUICustomization.getTextBox())
        XCTAssertNotNil(cardinalUICustomization.getToolbarCustomization())
    }

    // MARK: - BTPaymentActionThreeDSecureButtonType.cardinalValue

    func testCardinalValue_mapsEveryCaseByNameNotRawValue() {
        XCTAssertEqual(BTPaymentActionThreeDSecureButtonType.verify.cardinalValue, ButtonTypeVerify)
        XCTAssertEqual(BTPaymentActionThreeDSecureButtonType.continue.cardinalValue, ButtonTypeContinue)
        XCTAssertEqual(BTPaymentActionThreeDSecureButtonType.next.cardinalValue, ButtonTypeNext)
        XCTAssertEqual(BTPaymentActionThreeDSecureButtonType.cancel.cardinalValue, ButtonTypeCancel)
        XCTAssertEqual(BTPaymentActionThreeDSecureButtonType.resend.cardinalValue, ButtonTypeResend)
    }
}
