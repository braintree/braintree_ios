import Foundation

/// Options for the PayPal edit funding instrument flow with retry on failed attempts
///
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultErrorHandlingEditRequest {

    private let editPayPalVaultID: String
    private let riskCorrelationID: String
    private let merchantAccountID: String?

    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side requests,
    ///   `gateway.payment_method.find("payment_method_token")` or `gateway.customer.find("customer_id")`
    ///   - riskCorrelationID: Required: Unique id for each transaction used in subsequent retry in case of failure
    ///   - merchantAccountID: Optional: ID of the merchant account; if one is not provided the default will be used
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String, riskCorrelationID: String, merchantAccountID: String? = nil) {
        self.editPayPalVaultID = editPayPalVaultID
        self.merchantAccountID = merchantAccountID
        self.riskCorrelationID = riskCorrelationID
    }
}
