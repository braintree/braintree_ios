import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A model representing a user's address information returned by Visa Checkout.
/// Parses and stores address values from a BTJSON object.
@objc public class BTVisaCheckoutAddress: NSObject {

    /// The user's first name
    @objc public let firstName: String?

    /// The user's last name
    @objc public let lastName: String?

    /// The user's street address (e.g., "123 Main St")
    @objc public let streetAddress: String?

    /// Additional address information (e.g., apartment or suite number)
    @objc public let extendedAddress: String?

    /// The city or locality of the address
    @objc public let locality: String?

    /// The state or region of the address
    @objc public let region: String?

    /// The postal or ZIP code
    @objc public let postalCode: String?

    /// The two-letter ISO country code (e.g., "US")
    @objc public let countryCode: String?

    /// The user's phone number associated with the address
    @objc public let phoneNumber: String?

    /// Initializes a `BTVisaCheckoutAddress` from a BTJSON object.
    /// - Parameter json: A BTJSON object containing the address fields.
    @objc public init(json: BTJSON) {
        self.firstName = json["firstName"].asString()
        self.lastName = json["lastName"].asString()
        self.streetAddress = json["streetAddress"].asString()
        self.extendedAddress = json["extendedAddress"].asString()
        self.locality = json["locality"].asString()
        self.region = json["region"].asString()
        self.postalCode = json["postalCode"].asString()
        self.countryCode = json["countryCode"].asString()
        self.phoneNumber = json["phoneNumber"].asString()
        super.init()
    }

    /// Convenience method for creating an address object from JSON.
    /// - Parameter json: A BTJSON object containing the address fields.
    /// - Returns: An initialized `BTVisaCheckoutAddress` instance.
    @objc public static func address(with json: BTJSON) -> BTVisaCheckoutAddress {
        return BTVisaCheckoutAddress(json: json)
    }
}

