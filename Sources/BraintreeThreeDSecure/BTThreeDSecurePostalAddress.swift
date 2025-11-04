import Foundation

/// Postal address for 3D Secure flows
@objcMembers public class BTThreeDSecurePostalAddress: NSObject {

    // MARK: - Public Properties

    /// Optional. Given name associated with the address
    public var givenName: String?

    /// Optional. Surname associated with the address
    public var surname: String?

    /// Optional. Line 1 of the Address (eg. number, street, etc)
    public var streetAddress: String?

    /// Optional. Line 2 of the Address (eg. suite, apt #, etc.)
    public var extendedAddress: String?

    /// Optional. Line 3 of the Address (eg. suite, apt #, etc.)
    public var line3: String?

    /// Optional. City name
    public var locality: String?

    /// Optional. Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    public var region: String?

    /// Optional. Zip code or equivalent is usually required for countries that have them.
    /// For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code
    public var postalCode: String?

    /// Optional. 2 letter country code
    public var countryCodeAlpha2: String?

    /// Optional. The phone number associated with the address
    /// - Note: Only numbers. Remove dashes, parentheses and other characters
    public var phoneNumber: String?
}
