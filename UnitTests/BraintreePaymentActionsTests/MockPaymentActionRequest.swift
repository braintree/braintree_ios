import Foundation
@testable import BraintreeCore
@testable import BraintreePaymentActions

class MockPaymentActionRequest: BTPaymentActionRequest {
    
    /// When set, `paymentMethodParameters()` throws this error instead of returning a value.
    var stubbedError: Error?
    
    override func paymentMethodParameters() throws -> any Encodable {
        if let stubbedError {
            throw stubbedError
        }
        return ["type": "MOCK"]
    }
}
