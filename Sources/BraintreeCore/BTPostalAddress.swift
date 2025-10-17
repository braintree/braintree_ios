import Foundation

///  Generic postal address
@objcMembers public class BTPostalAddress: NSObject, Encodable {

    // MARK: - Internal Properties
    
    // Property names follow the `Braintree_Address` convention as documented at:
    // https://developer.paypal.com/braintree/docs/reference/request/address/create
    let recipientName: String?
    let streetAddress: String?
    let extendedAddress: String?
    let locality: String?
    let countryCodeAlpha2: String?
    let postalCode: String?
    let region: String?
    
    // MARK: - Initializer
    
    /// Creats a postal address with all components
    /// - Parameters:
    ///    - recipientName: Optional. Recipient name for shipping address.
    ///    - streetAddress: Optional. Line 1 of the Address (eg. number, street, etc).
    ///    -  extendedAddress: Optional. Line 2 of the Address (eg. suite, apt #, etc.).
    ///    - locality: Optional. City name
    ///    - countryCodeAlpha2: Optional. 2 letter country code.
    ///    - postalCode: Optional. Zip code or equivalent is usually required for countries that have them. For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
    ///    - region: Optional. Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    public init(
        recipientName: String? = nil,
        streetAddress: String? = nil,
        extendedAddress: String? = nil,
        locality: String? = nil,
        countryCodeAlpha2: String? = nil,
        postalCode: String? = nil,
        region: String? = nil
    ) {
        self.recipientName = recipientName
        self.streetAddress = streetAddress
        self.extendedAddress = extendedAddress
        self.locality = locality
        self.countryCodeAlpha2 = countryCodeAlpha2
        self.postalCode = postalCode
        self.region = region
    }
    
    enum CodingKeys: String, CodingKey {
        case countryCodeAlpha2 = "country_code"
        case extendedAddress = "line2"
        case locality = "city"
        case postalCode = "postal_code"
        case region = "state"
        case recipientName = "recipient_name"
        case streetAddress = "line1"
    }
    
    // MARK: - Helper Method
    
    /// Returns address components as a dictionary for accessing internal properties across modules
    public func addressComponents() -> [String: String] {
        [
            "recipientName": recipientName,
            "streetAddress": streetAddress,
            "extendedAddress": extendedAddress,
            "locality": locality,
            "countryCodeAlpha2": countryCodeAlpha2,
            "postalCode": postalCode,
            "region": region
        ].compactMapValues { $0 }
    }
}
