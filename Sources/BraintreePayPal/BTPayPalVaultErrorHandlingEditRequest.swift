import Foundation

/// Options for the PayPal edit funding instrument flow with retry on failed attempts
///
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultErrorHandlingEditRequest {

    private let editPayPalVaultID: String
    private let riskCorrelationID: String
    private let merchantAccountID: String?

    //   TODO: specify endpoint for merchant to retrieve the EditResult
    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side request
    ///   - riskCorrelationID: Required: Unique id for each transaction used in subsequent retry in case of failure
    ///   - merchantAccountID: optional ID of the merchant account; if one is not provided the default will be used
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String, riskCorrelationID: String, merchantAccountID: String? = nil) {
        self.editPayPalVaultID = editPayPalVaultID
        self.merchantAccountID = merchantAccountID
        self.riskCorrelationID = riskCorrelationID
    }
}
