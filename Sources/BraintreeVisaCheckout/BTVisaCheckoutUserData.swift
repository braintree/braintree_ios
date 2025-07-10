import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// A class containing Visa Checkout information about the user.
@objcMembers public class BTVisaCheckoutUserData: NSObject {

    // The user's first name.
    public let userFirstName: String?
    
    // The user's last name.
    public let userLastName: String?
    
    // The user's full name.
    public let userFullName: String?
    
    // The user's username.
    public let username: String?
    
    // The user's email.
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
