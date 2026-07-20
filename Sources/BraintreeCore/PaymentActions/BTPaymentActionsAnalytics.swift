import Foundation

// TODO: These analytic constants are still under review and are subject to change.
enum BTPaymentActionsAnalytics {
    static let setPaymentMethodStarted = "payment-actions:set-payment-method:started"
    static let setPaymentMethodSucceeded = "payment-actions:set-payment-method:succeeded"
    static let setPaymentMethodFailed = "payment-actions:set-payment-method:failed"
    static let readyForConfirmation = "payment-actions:ready-for-confirmation"
}
