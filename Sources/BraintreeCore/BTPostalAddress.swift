import Foundation

///  Generic postal address
@objcMembers public class BTPostalAddress: NSObject, NSCopying {
    // Property names follow the `Braintree_Address` convention as documented at:
    // https://developer.paypal.com/braintree/docs/reference/request/address/create

    /// Optional. Recipient name for shipping address.
    public var recipientName: String? = nil

    /// Line 1 of the Address (eg. number, street, etc).
    public var streetAddress: String? = nil

    /// Optional line 2 of the Address (eg. suite, apt #, etc.).
    public var extendedAddress: String? = nil

    /// City name
    public var locality: String? = nil

    /// 2 letter country code.
    public var countryCodeAlpha2: String? = nil

    /// Zip code or equivalent is usually required for countries that have them.
    /// For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
    public var postalCode: String? = nil

    /// Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    public var region: String? = nil

    @objc(copyWithZone:)
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = BTPostalAddress()
        result.recipientName = self.recipientName
        result.streetAddress = self.streetAddress
        result.extendedAddress = self.extendedAddress
        result.locality = self.locality
        result.countryCodeAlpha2 = self.countryCodeAlpha2
        result.postalCode = self.postalCode
        result.region = self.region
        return result
    }
}
