import Foundation

enum BTPayPalNativeCheckoutAnalytics {
    
    // MARK: - Conversion Events
    
    static let tokenizeStarted = "paypal-native:tokenize:started"
    static let tokenizeFailed = "paypal-native:tokenize:failed"
    static let tokenizeSucceeded = "paypal-native:tokenize:succeeded"
    static let tokenizeCanceled = "paypal-native:tokenize:canceled"
    
    // MARK: - Additional Detail Events
    
    static let orderCreationFailed = "paypal-native:tokenize:order-creation:failed"
}
