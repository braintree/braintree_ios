import XCTest

extension XCTestCase {

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 30) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: element)
        
        waitForExpectations(timeout: timeout)
    }
    
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 30) {
        let existsPredicate = NSPredicate(format: "exists == true && hittable == true")
        
        expectation(for: existsPredicate, evaluatedWith: element)
        
        waitForExpectations(timeout: timeout)
    }
}

extension XCUIElement {

    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}

internal extension XCUIApplication {
    
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
    
    var visaCardNumberTextField: XCUIElement {
        return textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Card Number"))
    }

    var visaExpirationDateTextField: XCUIElement {
        return textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Expires"))
    }

    var visaSecurityCodeTextField: XCUIElement {
        return textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Security Code"))
    }

    var tokenizeButton: XCUIElement {
        return buttons["Tokenize and Verify New Card"]
    }

    var cardinalSubmitButton: XCUIElement {
        return buttons["SUBMIT"]
    }

    var liabilityShiftedMessage: XCUIElement {
        return buttons["Liability shift possible and liability shifted"]
    }
    
    var liabilityCouldNotBeShiftedMessage: XCUIElement {
        return buttons["3D Secure authentication was attempted but liability shift is not possible"]
    }

    var firstNameTextField: XCUIElement {
        return textFields["First Name"]
    }

    var lastNameTextField: XCUIElement {
        return textFields["Last Name"]
    }

    var addressLine1TextField: XCUIElement {
        return textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Address Line 1"))
    }

    var cityTextField: XCUIElement {
        return textFields["City"]
    }

    var stateTextField: XCUIElement {
        return textFields["State"]
    }

    var zipCodeTextField: XCUIElement {
        return textFields["Zip Code"]
    }

    var mobileNumberTextField: XCUIElement {
        return textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Mobile Number"))
    }

    var mobileNumberLabel: XCUIElement {
        return staticTexts["Mobile Number (Required)"]
    }

    var emailAddressTextField: XCUIElement {
        return textFields["Email Address"]
    }

    func enterCardDetailsWith(cardNumber: String, expirationDate: String = UITestDateGenerator.sharedInstance.futureDate()) {
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText(cardNumber)
        expirationDateTextField.forceTapElement()
        expirationDateTextField.typeText(expirationDate)
        if postalCodeTextField.exists {
            postalCodeTextField.forceTapElement()
            postalCodeTextField.typeText("12345")
            cvvTextField.forceTapElement()
            cvvTextField.typeText("123")
        }
    }

    func enterVisaCardDetailsWith(cardNumber: String, expirationDate: String = UITestDateGenerator.sharedInstance.futureDate()) {
        visaCardNumberTextField.forceTapElement()
        visaCardNumberTextField.typeText(cardNumber)
        visaExpirationDateTextField.forceTapElement()
        visaExpirationDateTextField.typeText(expirationDate)
        visaSecurityCodeTextField.forceTapElement()
        visaSecurityCodeTextField.typeText("123")
    }

    func enterBillingAddress(
        firstName: String? = nil,
        lastName: String? = nil,
        addressLine1: String,
        city: String,
        state: String,
        zipCode: String,
        mobileNumber: String? = nil,
        emailAddress: String? = nil
    ) {
        firstNameTextField.forceTapElement()
        firstNameTextField.typeText(firstName ?? "")
        lastNameTextField.forceTapElement()
        lastNameTextField.typeText(lastName ?? "")
        addressLine1TextField.forceTapElement()
        addressLine1TextField.typeText(addressLine1)
        cityTextField.forceTapElement()
        cityTextField.typeText(city)
        stateTextField.forceTapElement()
        stateTextField.typeText(state)
        zipCodeTextField.forceTapElement()
        zipCodeTextField.typeText(zipCode)
        mobileNumberLabel.forceTapElement()
        mobileNumberTextField.typeText(mobileNumber ?? "")
        swipeUp()
        emailAddressTextField.forceTapElement()
        emailAddressTextField.typeText(emailAddress ?? "")
        swipeUp()
    }
}

internal extension TimeInterval {

    static let threeDSecureTimeout = 30.0
}
