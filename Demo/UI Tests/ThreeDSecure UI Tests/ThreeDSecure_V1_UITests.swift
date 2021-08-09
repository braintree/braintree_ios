/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class ThreeDSecure_V1_UITests: XCTestCase {
    var app: XCUIApplication!

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

        waitForElementToAppear(app.unexpectedErrorMessage)
    }

    func testThreeDSecurePaymentFlowV1_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        app.enterCardDetailsWith(cardNumber: "4000000000000093")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.webViewPasswordTextField, timeout: .threeDSecureTimeout)

        app.webViewPasswordTextField.forceTapElement()
        sleep(2)
        app.webViewPasswordTextField.typeText("1234")

        app.webViewSubmitButton.tap()

        waitForElementToAppear(app.unexpectedErrorMessage)
    }

    func testThreeDSecurePaymentFlowV1_returnsToApp_whenCancelTapped() {
        app.enterCardDetailsWith(cardNumber: "4000000000000002")
        app.tokenizeButton.tap()

        waitForElementToAppear(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        waitForElementToAppear(app.buttons["Canceled 🎲"])
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

        waitForElementToAppear(app.liabilityCouldNotBeShiftedMessage, timeout:30)
    }
}
