import Foundation

enum BTCardAnalytics {

    // MARK: - Tokenize Events

    static let cardTokenizeStarted = "card:tokenize:started"
    static let cardTokenizeFailed = "card:tokenize:failed"
    static let cardTokenizeSucceeded = "card:tokenize:succeeded"
    
    // MARK: - Payment Action Events
    
    // TODO: The analytic constants below are currently placeholder values that may be changed when the final values are determined.
    static let paymentActionsSetPaymentMethodStarted = "card:payment-actions:set-payment-method:started"
    static let paymentActionsSetPaymentMethodSucceeded = "card:payment-actions:set-payment-method:succeeded"
    static let paymentActionsSetPaymentMethodFailed = "card:payment-actions:set-payment-method:failed"
}
