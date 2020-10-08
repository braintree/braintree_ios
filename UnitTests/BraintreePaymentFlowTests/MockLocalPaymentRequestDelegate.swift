import XCTest
import BraintreePaymentFlow

class MockLocalPaymentRequestDelegate : NSObject, BTLocalPaymentRequestDelegate {
    var paymentId: String?
    var idExpectation : XCTestExpectation?

    func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentId: String, start: @escaping () -> Void) {
        self.paymentId = paymentId
        idExpectation?.fulfill()
        start()
    }
}
