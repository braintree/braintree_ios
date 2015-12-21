/*
IMPORTRANT
Hardware keyboard should be disabled on simulator for tests to run reliably.
*/

import XCTest

class BraintreeThreeDSecure_ClientToken_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecureViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThreeDSecure_completesAuthentication_receivesNonce() {
        let app = XCUIApplication()
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        let elementsQuery = app.otherElements["Authentication"]
        let passwordTextField = elementsQuery.childrenMatchingType(.Other).childrenMatchingType(.SecureTextField).element
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")
        
        elementsQuery.buttons["Submit"].tap()
        
        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])
        
        XCTAssertTrue(app.buttons["Liability shift possible and liability shifted"].exists);
    }
    
    func testThreeDSecure_returnsToApp_whenCancelTapped() {
        let app = XCUIApplication()
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.navigationBars["Authentication"])
        
        app.navigationBars["Authentication"].buttons["Cancel"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }
    
    func testThreeDSecure_closesPopup_whenCancelTapped() {
        let app = XCUIApplication()
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.navigationBars["Authentication"])
        
        var elementsQuery = app.otherElements["Authentication"]
        
        elementsQuery.links["Help"].tap()
        
        self.waitForElementToAppear(app.navigationBars["Verified by Visa"])

        elementsQuery = app.otherElements["Verified by Visa"]
        
        elementsQuery.links["Social Security Number"].forceTapElement()
        
        sleep(1)
        
        app.navigationBars["Verified by Visa"].buttons["Cancel"].forceTapElement()
        
        self.waitForElementToAppear(app.navigationBars["Authentication"])
        
        XCTAssertTrue(app.navigationBars["Authentication"].exists);
    }
}
