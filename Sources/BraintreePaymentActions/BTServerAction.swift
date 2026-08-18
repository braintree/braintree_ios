import Foundation

/// The server-driven action the merchant/SDK must perform next to advance a Payment Action.
/// Only meaningful when `BTPaymentActionResult.type == .serverActionRequired`.
@objc public enum BTServerAction: Int {
    
    /// Not applicable. The associated `BTPaymentActionResult.type` is not `.serverActionRequired`
    case none
    
    /// The Payment Action must be confirmed.
    case confirm
    
    /// The Payment Action must be captured.
    case capture
}
