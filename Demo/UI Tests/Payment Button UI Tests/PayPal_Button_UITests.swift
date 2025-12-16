//
//  PayPal_Button_UITests.swift
//  UITests
//
//  Created by Brent Busby on 12/10/25.
//  Copyright © 2025 braintree. All rights reserved.
//

import XCTest

final class PayPal_Button_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PaymentButtonViewController")

        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    // loading test - starts w/ loading, then ends without

    // tests that it can onyl be tapped once - disabled after first tap

    func testPayPal_button_loadingState() {
        // Verify state is not in loading, enabled
        XCTAssertTrue(app.buttons["Pay with PayPal"].isEnabled)

        app.buttons["Pay with PayPal"].tap()

        XCTAssertFalse(app.buttons["Pay with PayPal"].isEnabled)

        // assert in loading
    }

    func testPayPalButton_tapLaunchesPayPalFlow() {
        app.buttons["Pay with PayPal"].tap()

        _ = springboard.buttons["Continue"].waitForExistence(timeout: 20.0)
        springboard.buttons["Continue"].tap()

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }
}
