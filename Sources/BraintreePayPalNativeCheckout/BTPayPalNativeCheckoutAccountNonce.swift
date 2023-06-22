import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

/// Contains information about a PayPal payment method.
@objcMembers public class BTPayPalNativeCheckoutAccountNonce: BTPaymentMethodNonce {

    // MARK: - Public Properties

    /// Payer's email address.
    public let email: String?

    /// Payer's first name.
    public let firstName: String?

    /// Payer's last name.
    public let lastName: String?

    /// Payer's phone number.
    public let phone: String?

    /// The billing address.
    public let billingAddress: BTPostalAddress?

    /// The shipping address.
    public let shippingAddress: BTPostalAddress?

    /// Client metadata id associated with this transaction.
    public let clientMetadataID: String?

    /// Optional. Payer id associated with this transaction.
    /// Will be provided for Vault and Checkout.
    public let payerID: String?

    // MARK: - Initializer

    init?(json: BTJSON, approvalData: ApprovalData? = nil) {
        let paypalAccounts = json["paypalAccounts"][0]
        guard let nonce = paypalAccounts["nonce"].asString() else {
            return nil
        }

        let isDefault = paypalAccounts["default"].isTrue
        let details = paypalAccounts["details"]
        let payerInfo = details["payerInfo"]

        clientMetadataID = details["correlationId"].asString()
        email = payerInfo["email"].asString() ?? details["email"].asString() ?? approvalData?.buyer?.email
        firstName = payerInfo["firstName"].asString() ?? approvalData?.buyer?.givenName
        lastName = payerInfo["lastName"].asString() ?? approvalData?.buyer?.familyName
        phone = payerInfo["phone"].asString()
        payerID = payerInfo["payerId"].asString() ?? approvalData?.buyer?.userId

        let shippingAddressJSON = details["payerInfo"]["shippingAddress"].asAddress()
        let accountAddressJSON =  details["payerInfo"]["accountAddress"].asAddress()
        shippingAddress = shippingAddressJSON ?? accountAddressJSON

        let billingAddressJSON = details["payerInfo"]["billingAddress"].asAddress()
        billingAddress = billingAddressJSON

        super.init(nonce: nonce, type: "PayPal", isDefault: isDefault)
    }
}
