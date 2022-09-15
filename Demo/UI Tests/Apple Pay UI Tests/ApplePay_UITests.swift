import XCTest

class ApplePay_UITests: XCTestCase {

    var app: XCUIApplication!
    var walletApp = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-SkipApplePayContactFields")
        app.launchArguments.append("-Integration:BraintreeDemoApplePayPassKitViewController")
        app.launch()
    }

    func testApplePayTokenizationReceivesNonce() {
        let applePayButton = app.buttons["Buy with Apple Pay"]
        waitForElementToBeHittable(applePayButton)
        applePayButton.tap()
        
        // On iOS < 16, the Payment Method view must be opened
        // so as to have the 'Pay with Passcode' button appear
        if #unavailable(iOS 16) {
            let cardPredicate = NSPredicate(format: "label CONTAINS '1234'")
            let cardButton = walletApp.buttons.containing(cardPredicate).firstMatch
            waitForElementToBeHittable(cardButton)
            cardButton.tap()
            
            let paymentMethodLabel = walletApp.staticTexts["Payment Method"]
            waitForElementToBeHittable(paymentMethodLabel)
            
            let closePredicate = NSPredicate(format: "label CONTAINS 'close'")
            let closeButton = walletApp.buttons.containing(closePredicate).element(boundBy: 1)
            closeButton.tap()
        }
        
        if UIDevice.current.systemVersion == "16.0" {
            XCTExpectFailure("PassbookUIService crashes on iOS 16.0 simulators")
        }
        
        let confirmButton = walletApp.buttons["Pay with Passcode"]
        waitForElementToBeHittable(confirmButton)
        confirmButton.tap()
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }
}
