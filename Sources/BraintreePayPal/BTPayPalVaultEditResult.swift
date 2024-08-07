import Foundation
import BraintreeCore

/// A result of the Edit FI flow used to display a customers updated payment details in your UI
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultEditResult {

    // MARK: - Public Properties

    /// This ID is used to link subsequent retry attempts if payment is declined
    public let clientMetadataID: String

    /// ID of the payer
    public let payerID: String?

    /// email address of the payer
    public let email: String?

    /// first name of the payer
    public let firstName: String?

    /// last name of the payer
    public let lastName: String?

    /// phone number of the payer
    public let phone: String?

    /// shipping address of the payer
    public let shippingAddress: BTPostalAddress?

    /// description of the funding source
    public let fundingSourceDescription: String?
}
