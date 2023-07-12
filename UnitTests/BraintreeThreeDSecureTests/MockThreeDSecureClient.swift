import Foundation
@testable import BraintreeThreeDSecure

class MockThreeDSecureClient: BTThreeDSecureClient {

    override func prepareLookup(request: BTThreeDSecureRequest, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}
