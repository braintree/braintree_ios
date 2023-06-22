import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a Venmo Account payment method
@objcMembers public class BTVenmoAccountNonce: BTPaymentMethodNonce {

    // MARK: - Public Properties

    /// The email associated with the Venmo account
    public var email: String?

    /// The external ID associated with the Venmo account
    public var externalID: String?

    /// The first name associated with the Venmo account
    public var firstName: String?

    /// The last name associated with the Venmo account
    public var lastName: String?

    /// The phone number associated with the Venmo account
    public var phoneNumber: String?

    /// The username associated with the Venmo account
    public var username: String?
    
    /// The primary billing address associated with the Venmo account
    public var billingAddress: BTPostalAddress?
    
    /// The primary shipping address associated with the Venmo account
    public var shippingAddress: BTPostalAddress?

    // MARK: - Initializers

    init(with nonce: String, username: String, isDefault: Bool) {
        self.username = username
        super.init(nonce: nonce, type: "Venmo", isDefault: isDefault)
    }

    convenience init(with paymentContextJSON: BTJSON) {
        self.init(
            with: paymentContextJSON["data"]["node"]["paymentMethodId"].asString() ?? "",
            username: paymentContextJSON["data"]["node"]["userName"].asString() ?? "",
            isDefault: false
        )

        let payerInfo = paymentContextJSON["data"]["node"]["payerInfo"]
        email = payerInfo["email"].asString()
        externalID = payerInfo["externalId"].asString()
        firstName = payerInfo["firstName"].asString()
        lastName = payerInfo["lastName"].asString()
        phoneNumber = payerInfo["phoneNumber"].asString()
        billingAddress = payerInfo["billingAddress"].asAddress()
        shippingAddress = payerInfo["shippingAddress"].asAddress()
    }

    // MARK: - Internal Methods

    static func venmoAccount(with json: BTJSON) -> BTVenmoAccountNonce {
        BTVenmoAccountNonce(
            with: json["nonce"].asString() ?? "",
            username: json["details"]["username"].asString() ?? "",
            isDefault: json["default"].isTrue
        )
    }
}
