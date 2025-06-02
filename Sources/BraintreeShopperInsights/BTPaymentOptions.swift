import Foundation

/// A single payment recommendation
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTPaymentOptions {

    /// The payment option type
    public let paymentOption: String
    
    /// The rank of the payment option
    public let recommendedPriority: Int
}
