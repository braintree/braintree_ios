import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

@objcMembers public class BTVisaCheckoutUserData: NSObject {

    @objc public let userFirstName: String?
    @objc public let userLastName: String?
    @objc public let userFullName: String?
    @objc public let username: String?
    @objc public let userEmail: String?

    @objc public init(json: BTJSON) {
        self.userFirstName = json["userFirstName"].asString()
        self.userLastName = json["userLastName"].asString()
        self.userFullName = json["userFullName"].asString()
        self.username = json["userName"].asString()
        self.userEmail = json["userEmail"].asString()
        super.init()
    }

    @objc public static func userData(with json: BTJSON) -> BTVisaCheckoutUserData {
        return BTVisaCheckoutUserData(json: json)
    }
}
