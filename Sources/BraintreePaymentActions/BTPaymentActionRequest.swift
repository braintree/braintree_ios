import Foundation

/// A payment method-specific request to submit to a Payment Action via `BTPaymentActionsClient`.
public protocol BTPaymentActionRequest {
    
    /// The ID of the Payment Action to submit this payment method for.
    var paymentActionID: String { get }
    
    /// The payment method payload for the `setPaymentActionPaymentMethod` GraphQL mutation's
    /// `paymentMethod` field. Each conforming type is responsible for encoding its own shape.
    func paymentMethodParameters() -> any Encodable
}
