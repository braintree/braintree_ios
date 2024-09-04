import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String
    public let merchantAccountID: String?
    let hermesPath: String = "v1/paypal_hermes/generate_edit_fi_url"

    // MARK: - Static properties

    static let callbackURLHostAndPath: String = "onetouch/v1"

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

    public func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]

        parameters["edit_paypal_vault_id"] = editPayPalVaultID

        parameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"

        return parameters
    }
}
