import Foundation

class BTPayPalNativeCheckoutAnalytics {
    
    // MARK: - Tokenize Events
    
    // Counted in conversion rates
    static let vaultRequestStarted = "paypal-native:vault-tokenize:started"
    static let checkoutRequestStarted = "paypal-native:checkout-tokenize:started"
    static let tokenizeFailed = "paypal-native:tokenize:failed"
    static let tokenizeSucceeded = "paypal-native:tokenize:succeeded"
    static let tokenizeCanceled = "paypal-native:tokenize:canceled"
    
    // Specific tokenize failures
    static let tokenizeUrlRequestFailed = "paypal-native:tokenize:url-request:failed"
    static let tokenizeParsingResultFailed = "paypal-native:tokenize:parsing-result:failed"
    
    // MARK: - Create Order Events
    
    static let createOrderStarted = "paypal-native:create-order:started"
    static let createOrderFailed = "paypal-native:create-order:failed"
    static let createOrderSucceeded = "paypal-native:create-order:succeeded"
    
    // Specific Create Order Fails
    static let createOrderPayPalNotEnabledFailed = "paypal-native:create-order:paypal-not-enabled:failed"
    static let createOrderClientIdNotFoundFailed = "paypal-native:create-order:client-id-not-found:failed"
    static let createOrderInvalidEnvironmentFailed = "paypal-native:create-order:invalid-environment:failed"
    static let createOrderHermesUrlRequestFailed = "paypal-native:create-order:hermes-url-request:failed"
    static let createOrderInvalidPaymentType =
        "paypal-native:create-order:invalid-payment-type:failed"
}
