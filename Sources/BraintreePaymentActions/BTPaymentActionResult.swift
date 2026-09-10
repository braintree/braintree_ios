import Foundation

/// The result of submitting a payment method to a Payment Action, mapped from the Payment Action's
/// lifecycle status into the next action the merchant should take.
@objcMembers public class BTPaymentActionResult: NSObject {
    
    // MARK: - Public Properties
    
    /// Required. The kind of result. Check this first to determine which other properties are populated.
    public let type: BTPaymentActionResultType
    
    /// Required. The Payment Action ID.
    public let id: String
    
    /// Optional: The server-driven action to perform next. Only applicable when `type == .serverActionRequired`; otherwise `nil`.
    public let serverAction: BTServerAction?
    
    // MARK: - Initializer
    
    init(type: BTPaymentActionResultType, id: String, serverAction: BTServerAction? = nil) {
        self.type = type
        self.id = id
        self.serverAction = serverAction
    }
}
