import Foundation
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class MockSEPADirectDebitAPI: SEPADirectDebitAPI {
    
    var cannedCreateMandateResult: CreateMandateResult?
    var cannedCreateMandateError: Error?

    override func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        completion(cannedCreateMandateResult, cannedCreateMandateError)
    }
}
