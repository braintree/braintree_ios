import Foundation

enum PayPalSavedPaymentMethodAnalytics {

    // MARK: - Initialization Events

    static let authorizationFailed = "paypal-saved-payment-method:init:authorization-failed"
    static let paymentMethodIDRequired = "paypal-saved-payment-method:init:payment-method-id-required"

    // MARK: - Funding Instrument Events

    static let stickyFIFetchStarted = "paypal-saved-payment-method:sticky-fi:fetch-started"
    static let stickyFIFetchSucceeded = "paypal-saved-payment-method:sticky-fi:fetch-succeeded"
    static let stickyFIFetchFailed = "paypal-saved-payment-method:sticky-fi:fetch-failed"

    static let fiRefreshStarted = "paypal-saved-payment-method:fi-refresh:started"
    static let fiRefreshSucceeded = "paypal-saved-payment-method:fi-refresh:succeeded"
    static let fiRefreshFailed = "paypal-saved-payment-method:fi-refresh:failed"

    static let renderSucceeded = "paypal-saved-payment-method:render:succeeded"
    static let editSelected = "paypal-saved-payment-method:edit:selected"

    // MARK: - Credit Messaging Events

    static let creditMessagingFetchStarted = "paypal-saved-payment-method:credit-messaging:fetch-started"
    static let creditMessagingFetchFailed = "paypal-saved-payment-method:credit-messaging:fetch-failed"
    static let creditMessagingRenderSucceeded = "paypal-saved-payment-method:credit-messaging:render-succeeded"
    static let creditMessagingLearnMoreSelected = "paypal-saved-payment-method:credit-messaging-learn-more:selected"
}
