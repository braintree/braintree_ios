import Foundation

@objc public class BTVisaCheckoutAddress: NSObject {

    @objc public let firstName: String?
    @objc public let lastName: String?
    @objc public let streetAddress: String?
    @objc public let extendedAddress: String?
    @objc public let locality: String?
    @objc public let region: String?
    @objc public let postalCode: String?
    @objc public let countryCode: String?
    @objc public let phoneNumber: String?

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

    @objc public static func address(with json: BTJSON) -> BTVisaCheckoutAddress {
        return BTVisaCheckoutAddress(json: json)
    }
}
