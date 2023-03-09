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

    // MARK: - Initializers

    init(with nonce: String, username: String, isDefault: Bool) {
        self.username = username
        super.init(nonce: nonce, type: "Venmo", isDefault: isDefault)
    }

    public convenience init(with paymentContextJSON: BTJSON) {
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
    }

    // MARK: - Internal Methods

    // TODO: remove public and make non-objc once BTVenmoClient is in Swift
    @objc(venmoAccountWithJSON:)
    public static func venmoAccount(with json: BTJSON) -> BTVenmoAccountNonce? {
        BTVenmoAccountNonce(
            with: json["nonce"].asString() ?? "",
            username: json["details"]["username"].asString() ?? "",
            isDefault: json["default"].isTrue
        )
    }
}
