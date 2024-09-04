import Foundation

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public struct BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String
    private let merchantAccountID: String?

    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side requests,
    ///   `gateway.payment_method.find("payment_method_token")` or `gateway.customer.find("customer_id")`
    ///   - merchantAccountID: Optional: ID of the merchant account; if one is not provided the default will be used
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String, merchantAccountID: String? = nil) {
        self.editPayPalVaultID = editPayPalVaultID
        self.merchantAccountID = merchantAccountID
    }
}
