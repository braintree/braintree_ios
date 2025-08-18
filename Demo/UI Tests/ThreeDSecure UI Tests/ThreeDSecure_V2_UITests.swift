import XCTest

class ThreeDSecure_V2_UITests: XCTestCase {
   
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    let expirationDate = UITestDateGenerator.sharedInstance.threeDSecure2TestingDate()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-UITestHardcodedClientToken")
        app.launchArguments.append("-Integration:ThreeDSecureViewController")
        app.launch()
    }

    func testThreeDSecurePaymentFlowV2_challengeFlow_andTransacts() {
        waitForElementToAppear(app.cardNumberTextField)
        app.enterCardDetailsWith(cardNumber: "4000000000001091", expirationDate: expirationDate)
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)

        let textField = app.textFields.element(boundBy: 1)
        waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()
        sleep(2)

        waitForElementToAppear(app.liabilityShiftedMessage)
        
        //ddd
        
        waitForElementToAppear(app.cardNumberTextField)
        app.enterCardDetailsWith(cardNumber: "4000000000001109", expirationDate: expirationDate)
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)
        
        let newTextField = app.secureTextFields.element(boundBy: 1)
        waitForElementToBeHittable(newTextField)
        newTextField.forceTapElement()
        sleep(2)
        newTextField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage, timeout: 30)
    }
    
//    func testThreeDSecurePaymentFlowV2_challengeFlow_andFails() {
//        waitForElementToAppear(app.cardNumberTextField)
//        app.enterCardDetailsWith(cardNumber: "4000000000001109", expirationDate: expirationDate)
//        app.tokenizeButton.tap()
//        sleep(2)
//
//        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)
//        
//        let textField = app.secureTextFields.element(boundBy: 1)
//        waitForElementToBeHittable(textField)
//        textField.forceTapElement()
//        sleep(2)
//        textField.typeText("1234")
//
//        app.cardinalSubmitButton.forceTapElement()
//        sleep(2)
//
//        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage, timeout: 30)
//    }

    func testThreeDSecurePaymentFlowV2_returnsToApp_whenCancelTapped() {
        waitForElementToAppear(app.cardNumberTextField)
        app.enterCardDetailsWith(cardNumber: "4000000000001091")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.buttons["Close"])

        app.buttons["Close"].forceTapElement()

        waitForElementToAppear(app.buttons["Canceled 🎲"])
    }
}
