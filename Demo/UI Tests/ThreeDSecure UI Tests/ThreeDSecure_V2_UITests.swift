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

        let textField = app.textFields.element(boundBy: 0)
        
        waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()
        sleep(2)

        waitForElementToAppear(app.liabilityShiftedMessage)
    }
    
    func testThreeDSecurePaymentFlowV2_challengeFlow_andFails() {
        waitForElementToAppear(app.cardNumberTextField)
        app.enterCardDetailsWith(cardNumber: "4000000000001109", expirationDate: expirationDate)
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.staticTexts["Purchase Authentication"], timeout: .threeDSecureTimeout)

        let textField = app.textFields.allElementsBoundByIndex.first { $0.isHittable } ??
            app.secureTextFields.allElementsBoundByIndex.first { $0.isHittable } ??
            app.textFields.element(boundBy: 0)
        
        waitForElementToBeHittable(textField)
        textField.forceTapElement()
        sleep(2)
        textField.typeText("1234")

        app.cardinalSubmitButton.forceTapElement()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage, timeout: 30)
    }

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
