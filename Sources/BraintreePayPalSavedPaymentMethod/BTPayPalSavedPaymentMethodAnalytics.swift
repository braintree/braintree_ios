import Foundation

enum BTPayPalSavedPaymentMethodAnalytics {

    // MARK: - Saved Payment Method Events

    static let savedPayPalPaymentMethodPresented = "ui-components:saved-paypal-payment-method-component:presented"
    static let savedPayPalPaymentMethodEditSelected = "ui-components:saved-paypal-payment-method-component:edit-selected"
    static let savedPayPalPaymentMethodFetchFailed = "ui-components:saved-paypal-payment-method-component:sticky-fi:fetch-failed"

    // MARK: - Credit Messaging Events

    static let creditMessagingPresented = "ui-components:saved-paypal-payment-method-component:credit-messaging:presented"
    static let creditMessagingSelected = "ui-components:saved-paypal-payment-method-component:credit-messaging:selected"
    static let creditMessagingFailed = "ui-components:saved-paypal-payment-method-component:credit-messaging:failed"
}
