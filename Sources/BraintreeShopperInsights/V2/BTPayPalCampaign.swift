import Foundation

/// Creates a BTPayPalCampaign
/// - Parameter id: The campaign identifier associated between PayPal and the merchant/partner.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTPayPalCampaign: Encodable {
    let id: String
    
    public init(id: String) {
        self.id = id
    }
}
