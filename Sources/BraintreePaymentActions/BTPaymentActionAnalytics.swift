import Foundation

enum BTPaymentActionAnalytics {
    
    // MARK: - Payment Action Events
    
    static let setPaymentActionPaymentMethodStarted = "payment-actions:set-payment-action-payment-method:started"
    static let setPaymentActionPaymentMethodSucceeded = "payment-actions:set-payment-action-payment-method:succeeded"
    static let setPaymentActionPaymentMethodFailed = "payment-actions:set-payment-action-payment-method:failed"
}
