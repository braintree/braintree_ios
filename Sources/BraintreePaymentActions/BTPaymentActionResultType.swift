import Foundation

/// The kind of `BTPaymentActionResult`. Check this before reading any of the result's other properties.
@objc public enum BTPaymentActionResultType: Int {
    
    /// The Payment Action completed successfully.
    case completed
    
    /// The Payment Action was canceled.
    case canceled
    
    /// The merchant/SDK must perform a server-driven action to proceed. See `serverAction`.
    case serverActionRequired
    
    /// The Payment Action requires a payment method to be submitted.
    case paymentMethodRequired
    
    /// The Payment Action requires the customer to complete an additional action.
    case customerActionRequired
    
    /// The Payment Action is still processing.
    case processing
    
    /// The Payment Action has expired.
    case expired

    /// The Payment Action status is unknown.
    case unknown
}
