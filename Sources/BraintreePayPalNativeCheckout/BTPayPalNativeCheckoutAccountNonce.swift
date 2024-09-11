import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
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

    init?(json: BTJSON, buyerData: User? = nil) {
        let paypalAccounts = json["paypalAccounts"][0]
        guard let nonce = paypalAccounts["nonce"].asString() else {
            return nil
        }

        let isDefault = paypalAccounts["default"].isTrue
        let details = paypalAccounts["details"]
        let payerInfo = details["payerInfo"]

        clientMetadataID = details["correlationId"].asString()
        email = payerInfo["email"].asString() ?? details["email"].asString() ?? buyerData?.email
        firstName = payerInfo["firstName"].asString() ?? buyerData?.givenName
        lastName = payerInfo["lastName"].asString() ?? buyerData?.familyName
        phone = payerInfo["phone"].asString()
        payerID = payerInfo["payerId"].asString() ?? buyerData?.userId

        let shippingAddressJSON = details["payerInfo"]["shippingAddress"].asAddress()
        let accountAddressJSON = details["payerInfo"]["accountAddress"].asAddress()
        shippingAddress = shippingAddressJSON ?? accountAddressJSON

        let billingAddressJSON = details["payerInfo"]["billingAddress"].asAddress()
        billingAddress = billingAddressJSON

        super.init(nonce: nonce, type: "PayPal", isDefault: isDefault)
    }
}
