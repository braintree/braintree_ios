import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The result of calling `submitForPaymentAction` on `BTCardPaymentActionsClient`.
/// - Note: This type currently only surfaces `id` and `status`. Additional fields (e.g.
///   `nextAction`, `selectedPaymentMethod`) may be added as M3 API review concludes.
@objcMembers public class BTCardPaymentActionResult: NSObject {
    
    /// The Payment Action ID. Pass this along to your server so it can call `confirmPaymentAction` or
    /// capture an endpoint as needed for the active flow.
    public let id: String
    
    /// The current lifecycle status of the Payment Action after the `setPaymentActionPaymentMethod` mutation call.
    public let status: BTPaymentActionStatus
    
    /// Creates a `BTCardPaymentActionResult`.
    ///  - Parameters:
    ///      - id: The Payment Action ID.
    ///      - status: The lifecycle status of the Payment Action.
    init(id: String, status: BTPaymentActionStatus) {
        self.id = id
        self.status = status
    }
}
