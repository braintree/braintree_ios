import Foundation

class BTVenmoAnalytics {
    
    // MARK: - Tokenize Request events
    
    static let tokenizeStarted = "venmo:tokenize:started"
    static let tokenizeFailed = "venmo:tokenize:failed"
    static let tokenizeNetworkConnectionLost = "venmo:tokenize:network-connection:failed"
    static let tokenizeSucceeded = "venmo:tokenize:succeeded"
    
    // MARK: - App Switch Events
    
    static let appSwitchSucceeded = "venmo:tokenize:app-switch:succeeded"
    static let appSwitchFailed = "venmo:tokenize:app-switch:failed"
    static let appSwitchCanceled = "venmo:tokenize:app-switch:canceled"
}
