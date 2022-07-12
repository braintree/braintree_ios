#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Contains information about a PayPal payment method.
@objc public class BTPayPalNativeCheckoutAccountNonce: NSObject {

    public let type: String = "PayPal"
    public let nonce: String
    public let isDefault: Bool

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
    let payerID: String?

    init?(json: BTJSON) {
        let paypalAccounts = json["paypalAccounts"][0]
        guard let localNonce = paypalAccounts["nonce"].asString() else {
            return nil
        }

        self.nonce = localNonce
        isDefault = paypalAccounts["default"].isTrue

        let details = paypalAccounts["details"]
        let payerInfo = details["payerInfo"]

        clientMetadataID = details["correlationId"].asString()
        email = payerInfo["email"].asString() ?? details["email"].asString()
        firstName = payerInfo["firstName"].asString()
        lastName = payerInfo["lastName"].asString()
        phone = payerInfo["phone"].asString()
        payerID = payerInfo["payerId"].asString()

        let shippingAddressJSON = details["payerInfo"]["shippingAddress"]
        let accountAddressJSON =  details["payerInfo"]["accountAddress"]
        shippingAddress = Self.addressFromJSON(shippingAddressJSON) ?? Self.accountAddressFromJSON(accountAddressJSON)

        let billingAddressJSON = details["payerInfo"]["billingAddress"]
        billingAddress = Self.addressFromJSON(billingAddressJSON)
    }

    private static func addressFromJSON(_ addressJSON: BTJSON) -> BTPostalAddress? {
        guard addressJSON.isObject else {
            return nil
        }
        let address = BTPostalAddress()
        address.recipientName = addressJSON["recipientName"].asString() // Likely to be nil
        address.streetAddress = addressJSON["line1"].asString()
        address.extendedAddress = addressJSON["line2"].asString()
        address.locality = addressJSON["city"].asString()
        address.region = addressJSON["state"].asString()
        address.postalCode = addressJSON["postalCode"].asString()
        address.countryCodeAlpha2 = addressJSON["countryCode"].asString()
        return address
    }

    private static func accountAddressFromJSON(_ addressJSON: BTJSON) -> BTPostalAddress? {
        if (!addressJSON.isObject) {
            return nil
        }
        let address = BTPostalAddress()
        address.recipientName = addressJSON["recipientName"].asString() // Likely to be nil
        address.streetAddress = addressJSON["street1"].asString()
        address.extendedAddress = addressJSON["street2"].asString()
        address.locality = addressJSON["city"].asString()
        address.region = addressJSON["state"].asString()
        address.postalCode = addressJSON["postalCode"].asString()
        address.countryCodeAlpha2 = addressJSON["country"].asString()
        return address
    }
}
