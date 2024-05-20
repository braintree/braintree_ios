import Foundation

/// A summary of the buyer's recommended payment methods.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTShopperInsightsResult {
    
    /// If true, display the PayPal button with high priority.
    public var isPayPalRecommended = false
    
    /// If true, dislpay the Venmo button with high priority.
    public var isVenmoRecommended = false
    
    /// If true, buyer is a member of the PayPal Inc. (PayPal, Venmo, Honey) network. 
    public var isEligibleInPayPalNetwork = false
}
