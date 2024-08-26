import Foundation

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String
    private let merchantAccountID: String?
    private let riskCorrelationID: String?

    //   TODO: specify endpoint for merchant to retrieve the token
    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side request
    ///   merchantAccountID: optional ID of the merchant account; if one is not provided the default will be used
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String, merchantAccountID: String? = nil, riskCorrelationID: String? = nil) {
        self.editPayPalVaultID = editPayPalVaultID
        self.merchantAccountID = merchantAccountID
        self.riskCorrelationID = riskCorrelationID
    }
}
