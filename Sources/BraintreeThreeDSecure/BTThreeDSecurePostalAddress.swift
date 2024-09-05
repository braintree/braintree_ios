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
    @_documentation(visibility: private)
    func asParameters(withPrefix prefix: String? = "") -> [String: String] {
        var parameters: [String: String?] = [
            prepend(prefix, toKey: "givenName"): givenName,
            prepend(prefix, toKey: "surname"): surname,
            prepend(prefix, toKey: "line1"): streetAddress,
            prepend(prefix, toKey: "line2"): extendedAddress,
            prepend(prefix, toKey: "line3"): line3,
            prepend(prefix, toKey: "city"): locality,
            prepend(prefix, toKey: "state"): region,
            prepend(prefix, toKey: "postalCode"): postalCode,
            prepend(prefix, toKey: "countryCode"): countryCodeAlpha2
        ]

        let phoneKey: String = prefix == "shipping" ? "phone" : "phoneNumber"
        parameters[prepend(prefix, toKey: phoneKey)] = phoneNumber

        // Remove all nil values and their key
        let filteredParameters: [String: String] = parameters.compactMapValues { $0 }

        return filteredParameters
    }

    // MARK: Private Methods

    private func prepend(_ prefix: String?, toKey key: String) -> String {
        if let prefix, !prefix.isEmpty {
            // Uppercase the first character in the key
            let firstLetter = key.prefix(1).capitalized
            let remainingLetters = key.dropFirst()
            return prefix + firstLetter + remainingLetters
        } else {
            return key
        }
    }
}
