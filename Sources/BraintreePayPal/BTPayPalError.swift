import Foundation

/// Error codes associated with PayPal.
public enum BTPayPalError: Int {
    /// Unknown error
    case unknown
    
    /// PayPal is disabled in configuration
    case disabled
    
    /// Invalid request, e.g. missing PayPal request
    case invalidRequest
    
    /// Braintree SDK is integrated incorrectly
    case integration
    
    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    case canceled
}
