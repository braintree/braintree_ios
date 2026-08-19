import Foundation

/// The result of submitting a payment method to a Payment Action, mapped from the Payment Action's
/// lifecycle status into the next action the merchant should take.
@objcMembers public class BTPaymentActionResult: NSObject {
    
    // MARK: - Internal Properties
    
    let type: BTPaymentActionResultType
    let id: String
    let serverAction: BTServerAction
    
    // MARK: - Initializer
    
    /// Initialize a `BTPaymentActionResult`
    /// - Parameters:
    ///   - type: Required: The kind of result. Check this first to determine which other properties are populated.
    ///   - id: Required: The Payment Action ID.
    ///   - serverAction: Required: The server-driven action to perform next. Only applicable when `type == .serverActionRequired`; otherwise `.none`.
    public init(type: BTPaymentActionResultType, id: String, serverAction: BTServerAction = .none) {
        self.type = type
        self.id = id
        self.serverAction = serverAction
    }
}
