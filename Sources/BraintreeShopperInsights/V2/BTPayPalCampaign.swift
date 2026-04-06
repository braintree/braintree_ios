import Foundation

/// Creates a BTPayPalCampaign
/// - Parameter id: The campaign identifier associated between PayPal and the merchant/partner.

public struct BTPayPalCampaign: Encodable {
    let id: String
    
    public init(id: String) {
        self.id = id
    }
}
