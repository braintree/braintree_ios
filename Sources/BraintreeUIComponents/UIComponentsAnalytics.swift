import Foundation

enum UIComponentsAnalytics {

    // MARK: - Card Fields Events

    static let cardFieldsPresented = "ui-components:card-fields:presented"
    static let cardFieldsValidated = "ui-components:card-fields:validated"

    // MARK: - PayPal Button Events

    static let payPalButtonPresented = "ui-components:paypal-button:presented"
    static let payPalButtonSelected = "ui-components:paypal-button:selected"

    // MARK: - Venmo Button Events

    static let venmoButtonPresented = "ui-components:venmo-button:presented"
    static let venmoButtonSelected = "ui-components:venmo-button:selected"

    // MARK: - PayPal Pay Later Button Events

    static let payLaterButtonPresented = "ui-components:pay-later-button:presented"
    static let payLaterButtonSelected = "ui-components:pay-later-button:selected"
}
