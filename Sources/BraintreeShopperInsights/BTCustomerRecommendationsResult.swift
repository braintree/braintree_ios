import Foundation

/// Customer recommendations for what payment options to show.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTCustomerRecommendationsResult {
    
    /// The session ID for the customer session.
    public let sessionID: String?
    
    /// Whether the customer is in the PayPal network.
    public let isInPayPalNetwork: Bool?
    
    /// The payment recommendations for the shopper.
    public let paymentRecommendations: [BTPaymentOptions]?
}
