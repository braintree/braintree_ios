import Foundation

enum BTVenmoAnalytics {

    // MARK: - Conversion Events
    
    static let tokenizeStarted = "venmo:tokenize:started"
    static let tokenizeFailed = "venmo:tokenize:failed"
    static let tokenizeSucceeded = "venmo:tokenize:succeeded"
    static let appSwitchCanceled = "venmo:tokenize:app-switch:canceled"
    
    // MARK: - Additional Conversion events

    static let handleReturnStarted = "venmo:tokenize:handle-return:started"
    
    // MARK: - App Switch Events
    
    static let appSwitchStarted = "venmo:tokenize:app-switch:started"
    static let appSwitchSucceeded = "venmo:tokenize:app-switch:succeeded"
    static let appSwitchFailed = "venmo:tokenize:app-switch:failed"
    
    // MARK: - Create Payment Context Events
    
    static let createPaymentContextStarted = "venmo:create-payment-context:started"
    static let createPaymentContextSucceeded = "venmo:create-payment-context:succeeded"
    static let createPaymentContextFailed = "venmo:create-payment-context:failed"
    
    // MARK: - Query Payment Context Events
    
    static let queryPaymentContextStarted = "venmo:query-payment-context:started"
    static let queryPaymentContextSucceeded = "venmo:query-payment-context:succeeded"
    static let queryPaymentContextFailed = "venmo:query-payment-context:failed"
}
