/*
IMPORTRANT
Hardware keyboard should be disabled on simulator for tests to run reliably.
Requires a local gateway.
*/

/*
 
import XCTest

class BraintreeThreeDSecure_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        let override = ["customer": 1,
                        "merchantAccountId": "three_d_secure_merchant_account",
                        "merchant_id": "integration_merchant_id",
                        "publicKey": "integration_public_key",
                        "tokenVersion": 2,
                        "overrides": []]
        let authRequest = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/merchants/integration_merchant_id/client_api/testing/client_token")!)
        authRequest.HTTPMethod = "POST"
        let postData = try! NSJSONSerialization.dataWithJSONObject(override, options: .PrettyPrinted)
        authRequest.HTTPBody = postData
        authRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let expectation = self.expectationWithDescription("Authorization loaded")
        NSURLSession.sharedSession().dataTaskWithRequest(authRequest) { (data, response, error) -> Void in
            super.setUp()
            do {
                guard let dat = data else { return }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { return }
                guard let clientToken = json["clientToken"] as? String else { return }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.app.launchArguments.append("-EnvironmentSandbox")
                    self.app.launchArguments.append("-ClientToken")
                    self.app.launchArguments.append("-Authorization:\(clientToken)")
                    self.app.launchArguments.append("-Integration:BraintreeDemoThreeDSecureViewController")
                    self.app.launch()
                })
                expectation.fulfill()
            } catch {
                print(error)
            }
        }.resume()
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testThreeDSecure_completesAuthentication_receivesNonce() {
        self.waitForElementToAppear(app.textFields["Card Number"])
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
    
    func testThreeDSecure_failsAuthentication() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000010")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        let elementsQuery = app.otherElements["Authentication"]
        let passwordTextField = elementsQuery.childrenMatchingType(.Other).childrenMatchingType(.SecureTextField).element
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")
        
        elementsQuery.buttons["Submit"].tap()
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_bypassesAuthentication_notEnrolled() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000051")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])
        
        XCTAssertTrue(app.buttons["Liability shift possible and liability shifted"].exists);
    }
    
    func testThreeDSecure_bypassesAuthentication_lookupFailed() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000077")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }
/*
    func testThreeDSecure_incorrectPassword() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000028")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        let elementsQuery = app.otherElements["Authentication"]
        let passwordTextField = elementsQuery.childrenMatchingType(.Other).childrenMatchingType(.SecureTextField).element
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("bad")
        
        elementsQuery.buttons["Submit"].tap()

        sleep(12)

        self.waitForElementToAppear(elementsQuery.staticTexts["Account Authentication Blocked"])

        elementsQuery.buttons["Continue"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }
    
    func testThreeDSecure_displaysLoading() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000101")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.otherElements["Visa Summary Page"])
        
        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])
    
        XCTAssertTrue(app.buttons["Liability shift possible and liability shifted"].exists);
    }
    
    func testThreeDSecure_returnsNonce_whenIssuerDown() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000036")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        let elementsQuery = app.otherElements["Authentication"]
        self.waitForElementToAppear(elementsQuery.staticTexts["System Error"])
        elementsQuery.buttons["Continue"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }
 */

    func testThreeDSecure_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000093")
        app.textFields["MM/YY"].typeText("122020")
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        let elementsQuery = app.otherElements["Authentication"]
        let passwordTextField = elementsQuery.childrenMatchingType(.Other).childrenMatchingType(.SecureTextField).element
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")
        
        elementsQuery.buttons["Submit"].tap()
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_returnsToApp_whenCancelTapped() {
        self.waitForElementToAppear(app.textFields["Card Number"])
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
    /*
    func testThreeDSecure_closesPopup_whenCancelTapped() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
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
 */
}
*/