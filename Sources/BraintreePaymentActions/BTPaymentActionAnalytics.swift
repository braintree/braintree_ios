import Foundation

enum BTPaymentActionAnalytics {
    
    // MARK: - Payment Action Events
    
    static let paymentActionsSetPaymentActionPaymentMethodStarted = "payment-actions:set-payment-action-payment-method:started"
    static let paymentActionsSetPaymentActionPaymentMethodSucceeded = "payment-actions:set-payment-action-payment-method:succeeded"
    static let paymentActionsSetPaymentActionPaymentMethodFailed = "payment-actions:set-payment-action-payment-method:failed"
}
