import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/**
 A class containing Visa Checkout information about the user's address.
 
 Parses and stores address values from a `BTJSON` object.

 - Properties:
   - firstName: The user's first name.
   - lastName: The user's last name.
   - streetAddress: The user's street address.
   - extendedAddress: The user's extended address.
   - locality: The user's locality.
   - region: The user's region.
   - postalCode: The user's postal code.
   - countryCode: The user's country code.
   - phoneNumber: The user's phone number.
 */
@objcMembers public class BTVisaCheckoutAddress: NSObject {

    /// The user's first name
    public let firstName: String?

    /// The user's last name
    public let lastName: String?

    /// The user's street address (e.g., "123 Main St")
    public let streetAddress: String?

    /// Additional address information (e.g., apartment or suite number)
    public let extendedAddress: String?

    /// The city or locality of the address
    public let locality: String?

    /// The state or region of the address
    public let region: String?

    /// The postal or ZIP code
    public let postalCode: String?

    /// The two-letter ISO country code (e.g., "US")
    public let countryCode: String?

    /// The user's phone number associated with the address
    public let phoneNumber: String?

    /// Initializes a `BTVisaCheckoutAddress` from a BTJSON object.
    /// - Parameter json: A BTJSON object containing the address fields.
    init(json: BTJSON) {
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
    public static func address(with json: BTJSON) -> BTVisaCheckoutAddress {
        return BTVisaCheckoutAddress(json: json)
    }
}
