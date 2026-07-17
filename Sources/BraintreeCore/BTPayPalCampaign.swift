import Foundation

/// A PayPal campaign applied to a checkout transaction.
@objcMembers public class BTPayPalCampaign: NSObject, Encodable {

    // MARK: - Public Properties

    public let id: String

    // MARK: - Public Initializer

    /// Initializes a PayPal campaign.
    /// - Parameter id: The PayPal campaign ID.
    public init(id: String) {
        self.id = id
    }
}
