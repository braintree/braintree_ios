import Foundation

class BTVenmoAnalytics {
    
    // MARK: - Conversion Events
    
    static let tokenizeStarted = "venmo:tokenize:started"
    static let tokenizeFailed = "venmo:tokenize:failed"
    static let tokenizeSucceeded = "venmo:tokenize:succeeded"    
    static let appSwitchCanceled = "venmo:tokenize:app-switch:canceled"
    
    // MARK: - Additional Detail Events
    
    static let appSwitchSucceeded = "venmo:tokenize:app-switch:succeeded"
    static let appSwitchFailed = "venmo:tokenize:app-switch:failed"
}
