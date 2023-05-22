import XCTest
import BraintreePaymentFlow

class MockLocalPaymentRequestDelegate : NSObject, BTLocalPaymentRequestDelegate {
    var paymentID: String?
    var idExpectation : XCTestExpectation?

    func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentID: String, start: @escaping () -> Void) {
        self.paymentID = paymentID
        idExpectation?.fulfill()
        start()
    }
}
