import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/**
 A class containing Visa Checkout information about the user.

 - Properties:
   - userFirstName: The user's first name.
   - userLastName: The user's last name.
   - userFullName: The user's full name.
   - username: The user's username.
   - userEmail: The user's email.
 */
@objcMembers public class BTVisaCheckoutUserData: NSObject {

    public let userFirstName: String?
    public let userLastName: String?
    public let userFullName: String?
    public let username: String?
    public let userEmail: String?

    init(json: BTJSON) {
        self.userFirstName = json["userFirstName"].asString()
        self.userLastName = json["userLastName"].asString()
        self.userFullName = json["userFullName"].asString()
        self.username = json["userName"].asString()
        self.userEmail = json["userEmail"].asString()
        super.init()
    }
}
