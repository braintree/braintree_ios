import Foundation

///  Generic postal address
@objcMembers public class BTPostalAddress: NSObject {

    // Property names follow the `Braintree_Address` convention as documented at:
    // https://developer.paypal.com/braintree/docs/reference/request/address/create

    /// Optional. Recipient name for shipping address.
    public var recipientName: String?

    /// Line 1 of the Address (eg. number, street, etc).
    public var streetAddress: String?

    /// Optional line 2 of the Address (eg. suite, apt #, etc.).
    public var extendedAddress: String?

    /// City name
    public var locality: String?

    /// 2 letter country code.
    public var countryCodeAlpha2: String?

    /// Zip code or equivalent is usually required for countries that have them.
    /// For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
    public var postalCode: String?

    /// Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    public var region: String?
}
