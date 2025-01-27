/// Contact information of the recipient for the order
public struct BTContactInformation {

    // MARK: - Internal Properties
    
    let recipientEmail: String?
    let recipientPhoneNumber: BTPayPalPhoneNumber?
    
    // MARK: - Initializer

    /// Intialize a BTContactInformation
    /// - Parameters:
    ///   - recipientEmail: Optional: Email address of the recipient.
    ///   - recipientPhoneNumber: Optional: Phone number of the recipient.
    public init(recipientEmail: String? = nil, recipientPhoneNumber: BTPayPalPhoneNumber? = nil) {
        self.recipientEmail = recipientEmail
        self.recipientPhoneNumber = recipientPhoneNumber
    }
}
