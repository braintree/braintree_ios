import Foundation

struct BTPaymentActionResult {
    
    public let id: String
    public let status: BTPaymentActionStatus
    // TODO: Add the nextAction result type in a later M4-related PR.
    public let nextAction: BTJSON?
    public let selectedPaymentMethod: BTPaymentActionSelectedPaymentMethod?
}

