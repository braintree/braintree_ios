import Foundation

enum BTVenmoAnalytics {

    // MARK: - Conversion Events
    
    static let tokenizeStarted = "venmo:tokenize:started"
    static let tokenizeFailed = "venmo:tokenize:failed"
    static let tokenizeSucceeded = "venmo:tokenize:succeeded"
    static let appSwitchCanceled = "venmo:tokenize:app-switch:canceled"
    
    // MARK: - Additional Conversion events

    static let handleReturnStarted = "venmo:tokenize:handle-return:started"
    
    // MARK: - App Switch events
    
    static let appSwitchStarted = "venmo:tokenize:app-switch:started"
    static let appSwitchSucceeded = "venmo:tokenize:app-switch:succeeded"
    static let appSwitchFailed = "venmo:tokenize:app-switch:failed"
}
