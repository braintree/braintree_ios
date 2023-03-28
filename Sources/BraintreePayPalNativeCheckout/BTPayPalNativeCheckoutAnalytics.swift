import Foundation

class BTPayPalNativeCheckoutAnalytics {
    
    // MARK: - Tokenize Events
    
    static let tokenizeStarted = "paypal-native:tokenize:started"
    static let tokenizeFailed = "paypal-native:tokenize:failed"
    static let tokenizeSucceeded = "paypal-native:tokenize:succeeded"
    static let tokenizeCanceled = "paypal-native:tokenize:canceled"
    
    // MARK: - Order Creation Fail
    
    static let orderCreateFailed = "paypal-native:order-create:failed"
}
