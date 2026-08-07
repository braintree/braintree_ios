import Foundation

/// A campaign displayed to the customer in the shopping journey.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct ShopperInsightsCampaign: Encodable {

    // MARK: - Internal Properties

    /// The PayPal campaign ID.
    let id: String

    // MARK: - Public Initializer

    /// Creates a ShopperInsightsCampaign.
    /// - Parameter id: Required. The PayPal campaign ID.
    public init(id: String) {
        self.id = id
    }
}
