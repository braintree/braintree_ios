import Foundation

/// The server-driven action the merchant/SDK must perform next to advance a Payment Action.
/// Only meaningful when `BTPaymentActionResult.type == .serverActionRequired`.
@objc public enum BTServerAction: Int {
    
    /// The Payment Action must be confirmed.
    case confirm
    
    /// The Payment Action must be captured.
    case capture
}
