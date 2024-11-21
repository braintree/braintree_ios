import XCTest

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

    func enterCardDetailsWith(cardNumber: String, expirationDate: String = UITestDateGenerator.sharedInstance.futureDate()) {
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

internal extension TimeInterval {
    
    static let threeDSecureTimeout = 30.0
}
