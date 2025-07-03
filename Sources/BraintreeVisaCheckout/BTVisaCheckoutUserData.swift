import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

@objcMembers public class BTVisaCheckoutUserData: NSObject {

    public let userFirstName: String?
    public let userLastName: String?
    public let userFullName: String?
    public let username: String?
    public let userEmail: String?

    @objc public init(json: BTJSON) {
        self.userFirstName = json["userFirstName"].asString()
        self.userLastName = json["userLastName"].asString()
        self.userFullName = json["userFullName"].asString()
        self.username = json["userName"].asString()
        self.userEmail = json["userEmail"].asString()
        super.init()
    }

    public static func userData(with json: BTJSON) -> BTVisaCheckoutUserData {
        return BTVisaCheckoutUserData(json: json)
    }
}
