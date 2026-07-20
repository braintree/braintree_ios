import Foundation
import BraintreeCore

public struct BTCardPaymentActionResult {
    public let id: String
    public let status: BTPaymentActionStatus
}
