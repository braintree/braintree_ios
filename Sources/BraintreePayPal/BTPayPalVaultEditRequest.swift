import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String

    // MARK: - Static properties

    static let callbackURLHostAndPath: String = "onetouch/v1/"

    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side requests,
    ///   `gateway.payment_method.find("payment_method_token")` or `gateway.customer.find("customer_id")`
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(editPayPalVaultID: String) {
        self.editPayPalVaultID = editPayPalVaultID
    }

    func parameters(riskCorrelationID: String) -> [String: Any] {
        [
            "edit_paypal_vault_id": editPayPalVaultID,
            "return_url": BTCoreConstants.callbackURLScheme + "://\(BTPayPalVaultEditRequest.callbackURLHostAndPath)success",
            "cancel_url": BTCoreConstants.callbackURLScheme + "://\(BTPayPalVaultEditRequest.callbackURLHostAndPath)cancel",
            "risk_correlation_id": riskCorrelationID
        ]
    }
}
