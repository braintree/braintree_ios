import Foundation

/// Postal address for 3D Secure flows
@objcMembers public class BTThreeDSecurePostalAddress: NSObject {

    // MARK: - Internal Properties

    var givenName: String?
    var surname: String?
    var streetAddress: String?
    var extendedAddress: String?
    var line3: String?
    var locality: String?
    var region: String?
    var postalCode: String?
    var countryCodeAlpha2: String?
    var phoneNumber: String?

    // MARK: - Initializer

    /// Creates a postal address for 3D Secure flows with all components
    /// - Parameters:
    ///    - givenName: Optional. Given name associated with the address
    ///    - surname: Optional. Surname associated with the address
    ///    - streetAddress: Optional. Line 1 of the Address (eg. number, street, etc)
    ///    - extendedAddress: Optional. Line 2 of the Address (eg. suite, apt #, etc.)
    ///    - line3: Optional. Line 3 of the Address (eg. suite, apt #, etc.)
    ///    - locality: Optional. City name
    ///    - region: Optional. Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    ///    - postalCode: Optional. Zip code or equivalent is usually required for countries that have them. For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code
    ///    - countryCodeAlpha2: Optional. 2 letter country code
    ///    - phoneNumber:Optional.  The phone number. Only numbers. Remove dashes, parentheses and other characters

    public init(
        givenName: String? = nil,
        surname: String? = nil,
        streetAddress: String? = nil,
        extendedAddress: String? = nil,
        line3: String? = nil,
        locality: String? = nil,
        region: String? = nil,
        postalCode: String? = nil,
        countryCodeAlpha2: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.givenName = givenName
        self.surname = surname
        self.streetAddress = streetAddress
        self.extendedAddress = extendedAddress
        self.line3 = line3
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.countryCodeAlpha2 = countryCodeAlpha2
        self.phoneNumber = phoneNumber
    }
}
