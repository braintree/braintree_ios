import Foundation

enum BTPaymentActionAnalytics {
    
    // MARK: - Payment Action Events
    
    static let paymentActionsSetPaymentMethodStarted = "card:payment-actions:set-payment-method:started"
    static let paymentActionsSetPaymentMethodSucceeded = "card:payment-actions:set-payment-method:succeeded"
    static let paymentActionsSetPaymentMethodFailed = "card:payment-actions:set-payment-method:failed"
}
