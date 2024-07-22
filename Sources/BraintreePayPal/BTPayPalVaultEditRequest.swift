import Foundation

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String

    //   TODO: specify endpoint for merchant to retrieve the token
    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side request
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String) {
        self.editPayPalVaultID = editPayPalVaultID
    }
}
