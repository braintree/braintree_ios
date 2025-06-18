import Foundation

@objc public class BTVisaCheckoutUserData: NSObject {

    @objc public let firstName: String?
    @objc public let lastName: String?
    @objc public let fullName: String?
    @objc public let username: String?
    @objc public let email: String?

    @objc public init(json: BTJSON) {
        self.firstName = json["userFirstName"].asString()
        self.lastName = json["userLastName"].asString()
        self.fullName = json["userFullName"].asString()
        self.username = json["userName"].asString()
        self.email = json["userEmail"].asString()
        super.init()
    }

    @objc public static func userData(with json: BTJSON) -> BTVisaCheckoutUserData {
        return BTVisaCheckoutUserData(json: json)
    }
}
