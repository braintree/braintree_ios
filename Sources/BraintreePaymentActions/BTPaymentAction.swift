import Foundation

/// The raw result of a Payment Actions `setPaymentActionPaymentMethod` GraphQL call.
struct BTPaymentAction {
    
    // MARK: - Internal Properties
    
    let id: String
    let status: BTPaymentActionStatus
}
