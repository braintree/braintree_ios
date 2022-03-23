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
        guard let sepaDirectDebitData = try? JSONEncoder().encode(sepaDirectDebitRequest) else {
            completion(nil, SEPADirectDebitError.createMandateEncodingFailure)
            return
        }

        let request = buildURLRequest(withComponent: "merchants/pwpp_multi_account_merchant/client_api/v1/sepa_debit", httpBody: sepaDirectDebitData)
        
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
                completion(nil, SEPADirectDebitError.invalidResult)
            }
        }
        task.resume()
    }
    
    func tokenize(
        ibanLastFour: String,
        customerId: String,
        bankReferenceToken: String,
        mandateType: String,
        completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void
    ) {
        let json: [String: Any] = [
            "sepa_debit_account": [
                "iban_last_chars": ibanLastFour,
                "customer_id": customerId,
                "bank_reference_token": bankReferenceToken,
                "mandate_type": mandateType
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            completion(nil, SEPADirectDebitError.tokenizeJSONSerializationFailure)
            return
        }

        let request = buildURLRequest(withComponent: "merchants/pwpp_multi_account_merchant/client_api/v1/payment_methods/sepa_debit_accounts", httpBody: jsonData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let result = BTSEPADirectDebitNonce(json: BTJSON(data: data))
            DispatchQueue.main.async {
                completion(result, nil)
            }
        }
        task.resume()
    }
    
    func buildURLRequest(withComponent component: String, httpBody: Data) -> URLRequest {
        let baseURL = URL(string: "http://localhost:3000")?.appendingPathComponent(component)
        var request = URLRequest(url: (baseURL)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("development_testing_pwpp_multi_account_merchant", forHTTPHeaderField: "Client-Key")
        request.httpMethod = "POST"
        request.httpBody = httpBody
        
        return request
    }
}
