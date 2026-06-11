import XCTest

final class CardFields_UITests: XCTestCase {

    var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:UIComponentsViewController")
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()
    }

    // MARK: - Pay Button State

    func testCardFields_payButtonInitiallyDisabled_enabledAfterValidInput() {
        let payButton = app.buttons["Pay"]
        XCTAssertTrue(payButton.waitForExistence(timeout: 5), "Pay button should be visible")
        XCTAssertFalse(payButton.isEnabled, "Pay button should be disabled when card fields are empty")

        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("4111111111111111")

        let expirationField = app.textFields["Expiration Date"]
        expirationField.tap()
        expirationField.typeText("1245")

        let cvvField = app.textFields["CVV"]
        cvvField.tap()
        cvvField.typeText("123")

        XCTAssertTrue(payButton.isEnabled, "Pay button should be enabled after valid card details are entered")
    }

    // MARK: - Validation Errors

    func testCardFields_showsError_whenInvalidDataIsEntered() {
        let cardNumberField = app.textFields["Card Number"]
        let expirationField = app.textFields["Expiration Date"]
        let cvvField = app.textFields["CVV"]

        // Enter incomplete card number (10 of 16 digits), then advance focus
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("4111111111")

        expirationField.tap()
        XCTAssertTrue(
            app.staticTexts["Card number is invalid"].waitForExistence(timeout: 2),
            "Error should appear below card number field after leaving with incomplete number"
        )

        // Advance to CVV without entering an expiration date
        cvvField.tap()
        XCTAssertTrue(
            app.staticTexts["Expiration date is required"].waitForExistence(timeout: 2),
            "Error should appear below expiration field after leaving it empty"
        )

        // Enter only 2 CVV digits, then advance focus
        cvvField.typeText("12")
        expirationField.tap()
        XCTAssertTrue(
            app.staticTexts["CVV is invalid"].waitForExistence(timeout: 2),
            "Error should appear below CVV field after leaving with incomplete CVV"
        )

        // Correct all fields and verify Pay button becomes enabled
        cardNumberField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        cardNumberField.typeText("4111111111111111")

        expirationField.typeText("1245")

        cvvField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        cvvField.typeText("123")
        
        waitForElementToBeHittable(app.buttons["Pay"])

        XCTAssertTrue(
            app.buttons["Pay"].isEnabled,
            "Pay button should be enabled after correcting all fields"
        )
    }

    // MARK: - Card Brand Detection

    func testCardFields_displaysVisaBrand_whenCardStartsWith4() {
        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("4")
        XCTAssertTrue(app.images["Visa"].waitForExistence(timeout: 2))
    }

    func testCardFields_displaysMastercardBrand_whenCardStartsWith51() {
        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("51")
        XCTAssertTrue(app.images["Mastercard"].waitForExistence(timeout: 2))
    }

    func testCardFields_displaysAmexBrand_whenCardStartsWith34() {
        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("34")
        XCTAssertTrue(app.images["American Express"].waitForExistence(timeout: 2))
    }

    func testCardFields_displaysDiscoverBrand_whenCardStartsWith6011() {
        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("6011")
        XCTAssertTrue(app.images["Discover"].waitForExistence(timeout: 2))
    }

    func testCardFields_displaysUnionPayBrand_whenCardStartsWith620() {
        let cardNumberField = app.textFields["Card Number"]
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("620")
        XCTAssertTrue(app.images["UnionPay"].waitForExistence(timeout: 2))
    }

    // MARK: - CVV Length Changes With Brand

    func testCardFields_showsCVVError_whenSwitchingFromAmexToVisa() {
        let cardNumberField = app.textFields["Card Number"]
        let expirationField = app.textFields["Expiration Date"]
        let cvvField = app.textFields["CVV"]

        waitForElementToBeHittable(cardNumberField)
        cardNumberField.tap()
        cardNumberField.typeText("378282246310005")

        expirationField.typeText("1245")

        cvvField.tap()
        cvvField.typeText("1234")

        cardNumberField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        cardNumberField.typeKey(.delete, modifierFlags: [])
        waitForElementToBeHittable(cardNumberField)
        cardNumberField.typeText("4111111111111111")

        cvvField.tap()
        expirationField.tap()

        XCTAssertTrue(
            app.staticTexts["CVV is invalid"].waitForExistence(timeout: 2),
            "CVV error should appear when a 4-digit Amex CVV is used after switching to a Visa card"
        )

        cvvField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        cvvField.typeText("123")

        waitForElementToBeHittable(app.buttons["Pay"])

        XCTAssertTrue(
            app.buttons["Pay"].isEnabled,
            "Pay button should be enabled after correcting CVV to 3 digits for Visa"
        )
    }
}
