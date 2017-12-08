/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeIdeal_UITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoIdealViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["Pay With iDEAL"])
        sleep(2)
    }
    
    func testIdeal_completesPayment_receivesCompleteStatus() {
        app.buttons["Pay With iDEAL"].tap()
        
        sleep(2)

        self.waitForElementToBeHittable(app.sheets.buttons["bunq"])
        app.sheets.buttons["bunq"].tap()
        
        sleep(2)
        
        app.otherElements.links["Continue"].tap()
        app.sheets["COMPLETE"].buttons["OK"].tap()
        
        self.waitForElementToAppear(app.buttons["iDEAL Status: COMPLETE"])
        XCTAssertTrue(app.buttons["iDEAL Status: COMPLETE"].exists);

        let existsStartedPredicate = NSPredicate(format: "label LIKE 'Started payment: PENDING *'")
        self.waitForElementToAppear(app.staticTexts.containing(existsStartedPredicate).element(boundBy: 0))
    }
    
    func testIdeal_cancels_whenDoneIsPressed() {
        app.buttons["Pay With iDEAL"].tap()
        
        sleep(2)

        self.waitForElementToBeHittable(app.sheets.buttons["bunq"])
        app.sheets.buttons["bunq"].tap()
        
        sleep(2)
        
        app.otherElements.buttons["Done"].tap()
        self.waitForElementToAppear(app.buttons["Cancelled🎲"])
        XCTAssertTrue(app.buttons["Cancelled🎲"].exists);
    }
}
