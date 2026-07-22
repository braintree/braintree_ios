import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTCardPaymentActionResult: NSObject {
    
    public let id: String
    public let status: BTPaymentActionStatus
    
    public init(id: String, status: BTPaymentActionStatus) {
        self.id = id
        self.status = status
    }
}
