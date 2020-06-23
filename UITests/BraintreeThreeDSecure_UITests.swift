/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeThreeDSecureLegacy_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecureViewController")
        app.launch()

        waitForElementToAppear(app.cardNumberTextField)
    }

    func testThreeDSecure_completesAuthentication_receivesNonce() {
        app.enterCardDetailsWith(cardNumber: "4000000000000002")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecure_failsAuthentication() {
        app.enterCardDetailsWith(cardNumber: "4000000000000010")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.authenticationFailedMessage)
    }

    func testThreeDSecure_bypassesAuthentication_notEnrolled() {
        app.enterCardDetailsWith(cardNumber: "4000000000000051")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecure_bypassesAuthentication_lookupFailed() {
        app.enterCardDetailsWith(cardNumber: "4000000000000077")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecure_incorrectPassword_callsBackWithError_exactlyOnce() {
        app.enterCardDetailsWith(cardNumber: "4000000000000028")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.authenticationFailedMessage)

        sleep(2)

        waitForElementToAppear(app.staticTexts["Callback Count: 1"])
    }

    func testThreeDSecure_passiveAuthentication_notPromptedForAuthentication() {
        app.enterCardDetailsWith(cardNumber: "4000000000000101")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecure_returnsNonce_whenIssuerDown() {
        app.enterCardDetailsWith(cardNumber: "4000000000000036")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.unxexpectedErrorMessage)
    }

    func testThreeDSecure_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        app.enterCardDetailsWith(cardNumber: "4000000000000093")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.unxexpectedErrorMessage)
    }

    func testThreeDSecure_returnsToApp_whenCancelTapped() {
        app.enterCardDetailsWith(cardNumber: "4000000000000002")
        app.tokenizeButton.tap()
        sleep(2)

        self.waitForElementToBeHittable(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        waitForElementToAppear(app.buttons["Cancelled🎲"])
    }

    func testThreeDSecure_bypassedAuthentication() {
        app.enterCardDetailsWith(cardNumber: "4000990000000004")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecure_lookupError() {
        app.enterCardDetailsWith(cardNumber: "4000000000000085")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecure_unavailable() {
        app.enterCardDetailsWith(cardNumber: "4000000000000069")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecure_timeout() {
        app.enterCardDetailsWith(cardNumber: "4000000000000044")
        app.tokenizeButton.tap()
        sleep(5)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }
}

class BraintreeThreeDSecurePaymentFlowV1_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecurePaymentFlowViewController")
        app.launch()

        waitForElementToAppear(app.cardNumberTextField)
    }

    func testThreeDSecurePaymentFlowV1_completesAuthentication_receivesNonce() {
        app.enterCardDetailsWith(cardNumber: "4000000000000002")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.forceTapElement()
        sleep(2)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_failsAuthentication() {
        app.enterCardDetailsWith(cardNumber: "5200000000000015")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.forceTapElement()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.authenticationFailedMessage)
    }

    func testThreeDSecurePaymentFlowV1_bypassesAuthentication_notEnrolled() {
        app.enterCardDetailsWith(cardNumber: "4000000000000051")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_bypassesAuthentication_lookupFailed() {
        app.enterCardDetailsWith(cardNumber: "4000000000000077")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_incorrectPassword_callsBackWithError_exactlyOnce() {
        app.enterCardDetailsWith(cardNumber: "4000000000000028")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.forceTapElement()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.authenticationFailedMessage)

        sleep(2)

        waitForElementToAppear(app.staticTexts["Callback Count: 1"])
    }

    func testThreeDSecurePaymentFlowV1_passiveAuthentication_notPromptedForAuthentication() {
        app.enterCardDetailsWith(cardNumber: "4000000000000101")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_returnsNonce_whenIssuerDown() {
        app.enterCardDetailsWith(cardNumber: "4000000000000036")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.tap()
        sleep(1)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.unxexpectedErrorMessage)
    }

    func testThreeDSecurePaymentFlowV1_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        app.enterCardDetailsWith(cardNumber: "4000000000000093")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.forceTapElement()
        sleep(2)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.unxexpectedErrorMessage)
    }

    func testThreeDSecurePaymentFlowV1_returnsToApp_whenCancelTapped() {
        app.enterCardDetailsWith(cardNumber: "4000000000000002")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.buttons["Done"])

        app.buttons["Done"].forceTapElement()

        waitForElementToAppear(app.buttons["Cancelled🎲"])
    }

    func testThreeDSecurePaymentFlowV1_bypassedAuthentication() {
        app.enterCardDetailsWith(cardNumber: "4000990000000004")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_lookupError() {
        app.enterCardDetailsWith(cardNumber: "4000000000000085")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_unavailable() {
        app.enterCardDetailsWith(cardNumber: "4000000000000069")
        app.tokenizeButton.tap()
        sleep(2)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }

    func testThreeDSecurePaymentFlowV1_timeout() {
        app.enterCardDetailsWith(cardNumber: "4000000000000044")
        app.tokenizeButton.tap()
        sleep(5)

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage)
    }
}

class BraintreeThreeDSecurePaymentFlowV2_UITests: XCTestCase {
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

        waitForElementToAppear(app.cardNumberTextField)
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
        app.enterCardDetailsWith(cardNumber: "5200000000001104", expirationDate: expirationDate)
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

fileprivate extension XCUIApplication {
    var cardNumberTextField: XCUIElement {
        return textFields["Card Number"]
    }

    var expirationDateTextField: XCUIElement {
        return textFields["MM/YY"]
    }

    var postalCodeTextField: XCUIElement {
        return textFields["Postal Code"]
    }

    var cvvTextField: XCUIElement {
        return textFields["CVV"]
    }

    var tokenizeButton: XCUIElement {
        return buttons["Tokenize and Verify New Card"]
    }

    var webViewPasswordTextField: XCUIElement {
        return webViews.element.otherElements.children(matching: .other).children(matching: .secureTextField).element
    }

    var webViewSubmitButton: XCUIElement {
        return webViews.element.otherElements.children(matching: .other).children(matching: .other).buttons["Submit"]
    }

    var cardinalSubmitButton: XCUIElement {
        return buttons["SUBMIT"]
    }

    var liabilityShiftedMessage: XCUIElement {
        return buttons["Liability shift possible and liability shifted"]
    }

    var authenticationFailedMessage: XCUIElement {
        return buttons["Failed to authenticate, please try a different form of payment."]
    }

    var liabilityCouldNotBeShiftedMessage: XCUIElement {
        return buttons["3D Secure authentication was attempted but liability shift is not possible"]
    }

    var unxexpectedErrorMessage: XCUIElement {
        return buttons["An unexpected error occurred"]
    }

    func enterCardDetailsWith(cardNumber: String, expirationDate: String = DateGenerator.sharedInstance.futureDate()) {
        cardNumberTextField.tap()
        cardNumberTextField.typeText(cardNumber)
        expirationDateTextField.tap()
        expirationDateTextField.typeText(expirationDate)
        if postalCodeTextField.exists {
            postalCodeTextField.forceTapElement()
            postalCodeTextField.typeText("12345")
            cvvTextField.forceTapElement()
            cvvTextField.typeText("123")
        }
    }
}

fileprivate extension TimeInterval {
    static let threeDSecureTimeout = 20.0
}
