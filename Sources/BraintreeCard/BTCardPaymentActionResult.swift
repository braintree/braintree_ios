import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

public struct BTCardPaymentActionResult {
    
    public let id: String
    public let status: BTPaymentActionStatus
}
