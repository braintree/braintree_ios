import Foundation

/// A payment method-specific request to submit to a Payment Action via `BTPaymentActionsClient`.
/// This base class is public only because `BTPaymentActionsClient.submitForPaymentAction` and
/// public subclasses (e.g. `BTCardPaymentActionRequest`) both require it to be.
@objcMembers public class BTPaymentActionRequest: NSObject {
    
    // MARK: - Internal Properties
    
    /// The ID of the Payment Action to submit this payment method for.
    let paymentActionID: String
    
    public init(paymentActionID: String) {
        self.paymentActionID = paymentActionID
    }
    
    /// The payment method payload for the `setPaymentActionPaymentMethod` GraphQL mutation's
    /// `paymentMethod` field. Each subclass is responsible for overriding this and encoding its own shape.
    func paymentMethodParameters() throws -> any Encodable {
        throw BTPaymentActionError.missingParameters
    }
}
