import Foundation

/// The result of a Payment Actions `setPaymentActionPaymentMethod` GraphQL call. Each payment-method-specific
/// client maps this into its own public result type, surfacing fields only relevant to that payment method.
public struct BTPaymentActionResult {
    
    /// The Payment Action ID.
    let id: String
    
    /// The current lifecycle status of the Payment Action. See `BTPaymentActionStatus`.
    let status: BTPaymentActionStatus
}
