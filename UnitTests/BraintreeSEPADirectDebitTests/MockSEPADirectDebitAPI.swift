import Foundation
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class MockSEPADirectDebitAPI: SEPADirectDebitAPI {
    
    var cannedCreateMandateResult: CreateMandateResult?
    var cannedCreateMandateError: Error?
    
    var cannedTokenizePaymentMethodNonce: BTSEPADirectDebitNonce?
    var cannedTokenizeError: Error?

    override func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        completion(cannedCreateMandateResult, cannedCreateMandateError)
    }
    
    override func tokenize(createMandateResult: CreateMandateResult, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        completion(cannedTokenizePaymentMethodNonce, cannedTokenizeError)
    }
}
