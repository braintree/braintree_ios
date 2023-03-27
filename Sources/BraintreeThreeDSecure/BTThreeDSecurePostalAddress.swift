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

    // MARK: - Internal Methods

    /// :nodoc:
    /// The postal address as parameters which can be used for API requests.
    /// The prefix value will be prepended to each key in the return dictionary
    /// - Parameter prefix: The prefix to prepend to the key in the dictionary
    /// - Returns: A dictionary representing the postal address.
    @objc(asParametersWithPrefix:)
    public func asParameters(withPrefix prefix: String? = "") -> [String: String] {
        var parameters: [String: String] = [:]

        if let givenName {
            parameters[prepend(prefix, toKey: "givenName")] = givenName
        }

        if let surname {
            parameters[prepend(prefix, toKey: "surname")] = surname
        }

        if let streetAddress {
            parameters[prepend(prefix, toKey: "line1")] = streetAddress
        }

        if let extendedAddress {
            parameters[prepend(prefix, toKey: "line2")] = extendedAddress
        }

        if let line3 {
            parameters[prepend(prefix, toKey: "line3")] = line3
        }

        if let locality {
            parameters[prepend(prefix, toKey: "city")] = locality
        }

        if let region {
            parameters[prepend(prefix, toKey: "state")] = region
        }

        if let postalCode {
            parameters[prepend(prefix, toKey: "postalCode")] = postalCode
        }

        if let countryCodeAlpha2 {
            parameters[prepend(prefix, toKey: "countryCode")] = countryCodeAlpha2
        }

        if let phoneNumber {
            let key: String = prefix == "shipping" ? "phone" : "phoneNumber"
            parameters[prepend(prefix, toKey: key)] = phoneNumber
        }

        return parameters
    }

    // MARK: Private Methods

    private func prepend(_ prefix: String?, toKey key: String) -> String {
        if prefix != "", let prefix {
            // Uppercase the first character in the key
            let firstLetter = key.prefix(1).capitalized
            let remainingLetters = key.dropFirst()
            return prefix + firstLetter + remainingLetters
        } else {
            return key
        }
    }
}

// MARK: - NSCopying Protocol Conformance

extension BTThreeDSecurePostalAddress: NSCopying {

    public func copy(with zone: NSZone? = nil) -> Any {
        let postalAddress = BTThreeDSecurePostalAddress()
        postalAddress.givenName = givenName
        postalAddress.surname = surname
        postalAddress.streetAddress = streetAddress
        postalAddress.extendedAddress = extendedAddress
        postalAddress.line3 = line3
        postalAddress.locality = locality
        postalAddress.region = region
        postalAddress.postalCode = postalCode
        postalAddress.countryCodeAlpha2 = countryCodeAlpha2
        postalAddress.phoneNumber = phoneNumber
        return postalAddress
    }
}
