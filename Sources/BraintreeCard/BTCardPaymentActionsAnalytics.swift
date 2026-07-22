import Foundation

// TODO: These keys are currently placeholder values that must be changed when we get the official values.
enum BTCardPaymentActionsAnalytics {
    static let setPaymentMethodStarted = "payment-actions:set-payment-method:started"
    static let setPaymentMethodSucceeded = "payment-actions:set-payment-method:succeeded"
    static let setPaymentMethodFailed = "payment-actions:set-payment-method:failed"
    static let readyForConfirmation = "payment-actions:ready-for-confirmation"
}
