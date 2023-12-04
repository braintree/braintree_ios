import Foundation

/// A summary of the buyer's recommended payment methods.
/// - Note: This feature is in beta. It's public API may change in future releases.
@objcMembers public class BTShopperInsightsResult: NSObject {
    
    /// If true, display the PayPal button with high priority.
    public var isPayPalRecommended = false
    
    /// If true dislpay the Venmo button with high priority.
    public var isVenmoRecommended = false
}
