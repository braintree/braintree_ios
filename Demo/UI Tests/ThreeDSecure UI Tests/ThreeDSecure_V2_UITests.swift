import XCTest

class ThreeDSecure_V2_UITests: XCTestCase {
    var app: XCUIApplication!
    let expirationDate = DateGenerator.sharedInstance.threeDSecure2TestingDate()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecurePaymentFlowViewController")
        app.launch()

        _ = app.cardNumberTextField.waitForExistence(timeout: 10)
    }

    func testThreeDSecurePaymentFlowV2_frictionlessFlow_andTransacts() {
        app.enterCardDetailsWith(cardNumber: "4000000000001000", expirationDate: expirationDate)
        app.tokenizeButton.tap()

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV2_challengeFlow_andTransacts() {
        app.enterCardDetailsWith(cardNumber: "4000000000001091", expirationDate: expirationDate)
        app.tokenizeButton.tap()

        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)

        let textField = app.textFields.element(boundBy: 0)
        waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV2_noChallenge_andFails() {
        app.enterCardDetailsWith(cardNumber: "5200000000001013", expirationDate: expirationDate)
        app.tokenizeButton.tap()

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV2_challengeFlow_andFails() {
        app.enterCardDetailsWith(cardNumber: "4000000000001109", expirationDate: expirationDate)
        app.tokenizeButton.tap()

        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)

        let textField = app.textFields.element(boundBy: 0)
        waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }
}
