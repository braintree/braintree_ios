import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class SEPADirectDebitAPI {
    
    private let apiClient: BTAPIClient

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest
    ) async throws -> CreateMandateResult {
        let sepaDebitRequest = SEPADebitRequest(sepaDirectDebitRequest: sepaDirectDebitRequest)
        
        let (body, _) = try await apiClient.post("v1/sepa_debit", parameters: sepaDebitRequest)
        
        guard let body else {
            throw BTSEPADirectDebitError.noBodyReturned
        }
        
        let result = CreateMandateResult(json: body)
        return result
    }

    func tokenize(createMandateResult: CreateMandateResult) async throws -> BTSEPADirectDebitNonce {
        let sepaDebitAccountsRequest = SEPADebitAccountsRequest(createMandateResult: createMandateResult)
        
        let (body, _) = try await apiClient.post("v1/payment_methods/sepa_debit_accounts", parameters: sepaDebitAccountsRequest)
        
        guard let body else {
            throw BTSEPADirectDebitError.noBodyReturned
        }
        
        guard let result = BTSEPADirectDebitNonce(json: body) else {
            throw BTSEPADirectDebitError.failedToCreateNonce
        }
        return result
    }
}
