import Foundation
#if canImport(BraintreeCore)
import BraintreeCore
#endif

class SEPADirectDebitAPI {
    
    // TODO: Use BTAPIClient when in Sandbox
    
    func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        let request = buildRequest(sepaDirectDebitRequest: sepaDirectDebitRequest)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(CreateMandateResult.self, from: data)
                DispatchQueue.main.async {
                    completion(result, nil)
                }
            } catch {
                completion(nil, BTSEPADirectDebitError.invalidResult)
            }
        }
        task.resume()
    }
    
    func tokenize(ibanLastFour: String, customerId: String, bankReferenceToken: String, mandateType: String) {
        // TODO: implement (future PR)
    }
    
    func buildRequest(sepaDirectDebitRequest: BTSEPADirectDebitRequest) -> URLRequest {
        let sepaDirectDebitData = try? JSONEncoder().encode(sepaDirectDebitRequest)

        var baseURL = URL(string: "http://localhost:3000")
        baseURL = baseURL?.appendingPathComponent("merchants/pwpp_multi_account_merchant/client_api/v1/sepa_debit")

        var request = URLRequest(url: (baseURL)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("development_testing_pwpp_multi_account_merchant", forHTTPHeaderField: "Client-Key")
        request.httpMethod = "POST"
        request.httpBody = sepaDirectDebitData

        return request
    }
}
