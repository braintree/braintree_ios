/// Contact information of the recipient for the order
public struct BTContactInformation {

    /// Email address of the recipient
    let recipientEmail: String?
    
    /// Phone number of the recipient
    let recipientPhoneNumber: BTPayPalPhoneNumber?

    public init(recipientEmail: String? = nil, recipientPhoneNumber: BTPayPalPhoneNumber? = nil) {
        self.recipientEmail = recipientEmail
        self.recipientPhoneNumber = recipientPhoneNumber
    }
}
