import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class SEPADirectDebitAPI {
    
    private let apiClient: BTAPIClient
    
    @objc(initWithAPIClient:)
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        let sepaDebitRequest = SEPADebitRequest(sepaDirectDebitRequest: sepaDirectDebitRequest)
        apiClient.post("v1/sepa_debit", parameters: sepaDebitRequest) { body, _, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let body = body else {
                completion(nil, BTSEPADirectDebitError.noBodyReturned)
                return
            }

            let result = CreateMandateResult(json: body)
            completion(result, nil)
        }
    }

    func tokenize(createMandateResult: CreateMandateResult, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        let sepaDebitAccountsRequest = SEPADebitAccountsRequest(createMandateResult: createMandateResult)
        apiClient.post("v1/payment_methods/sepa_debit_accounts", parameters: sepaDebitAccountsRequest) { body, _, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let body = body else {
                completion(nil, BTSEPADirectDebitError.noBodyReturned)
                return
            }

            let result = BTSEPADirectDebitNonce(json: body)
            completion(result, nil)
        }
    }
}
