import XCTest
@testable import BraintreeCore
@testable import BraintreeThreeDSecure
@testable import BraintreePaymentFlow
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

class MockThreeDSecureRequestDelegate : NSObject, BTThreeDSecureRequestDelegate {
    var lookupCompleteExpectation : XCTestExpectation?

    func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult: BTThreeDSecureResult, next: @escaping () -> Void) {
        lookupCompleteExpectation?.fulfill()
        next()
    }
}
