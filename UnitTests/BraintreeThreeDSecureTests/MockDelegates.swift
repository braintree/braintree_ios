import XCTest
@testable import BraintreeCore
@testable import BraintreeThreeDSecure
@testable import BraintreeTestShared

class MockThreeDSecureRequestDelegate : NSObject, BTThreeDSecureRequestDelegate {
    var lookupCompleteExpectation : XCTestExpectation?

    func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult: BTThreeDSecureResult, next: @escaping () -> Void) {
        lookupCompleteExpectation?.fulfill()
        next()
    }
}
