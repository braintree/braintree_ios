import XCTest
import BraintreePaymentFlow
import BraintreeCore
@testable import BraintreeTestShared

class MockPaymentFlowClientDelegate: NSObject, BTPaymentFlowClientDelegate {
    var _returnURLScheme = ""

    var onPaymentWithURLHandler: ((URL?, Error?) -> Void)?
    var onPaymentCancelHandler: (() -> Void)?
    var onPaymentCompleteHandler: ((NSObject?, Error?) -> Void)?

    func onPayment(with url: URL?, error: Error?) {
        onPaymentWithURLHandler?(url, error)
    }

    func onPaymentCancel() {
        onPaymentCancelHandler?()
    }

    func onPaymentComplete(_ result: NSObject?, error: Error?) {
        onPaymentCompleteHandler?(result, error)
    }

    func returnURLScheme() -> String {
        return _returnURLScheme
    }

    func apiClient() -> BTAPIClient {
        return MockAPIClient(authorization: "development_tokenization_key")!
    }
}
