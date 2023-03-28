import Foundation

class BTPayPalNativeCheckoutAnalytics {
    
    // MARK: - Tokenize Events
    
    static let vaultRequestStarted = "paypal-native:vault-tokenize:started"
    static let checkoutRequestStarted = "paypal-native:checkout-tokenize:started"
    static let tokenizeFailed = "paypal-native:tokenize:failed"
    static let tokenizeSucceeded = "paypal-native:tokenize:succeeded"
    static let tokenizeCanceled = "paypal-native:tokenize:canceled"
}
