import Foundation

@objc
class BraintreeDemoMerchantAPIClient: NSObject {
    
    private struct ClientToken: Codable {

        let clientToken: String
    }

    private struct TransactionResponse: Codable {

        let message: String
    }
    
    @objc
    static let shared = BraintreeDemoMerchantAPIClient()
    
    private override init() {}
    
    @objc
    func createCustomerAndFetchClientToken(completion: @escaping (String?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: BraintreeDemoSettings.currentEnvironmentURLString + "/client_token") else { return }
        
        if BraintreeDemoSettings.customerPresent {
            if let id = BraintreeDemoSettings.customerIdentifier, !id.isEmpty {
                urlComponents.queryItems = [URLQueryItem(name: "customer_id", value: id)]
            } else {
                urlComponents.queryItems = [URLQueryItem(name: "customer_id", value: UUID().uuidString)]
            }
        }

        guard let url = urlComponents.url else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let clientToken = try? jsonDecoder.decode(ClientToken.self, from: data).clientToken
            DispatchQueue.main.async { completion(clientToken, nil) }
        }
        
        task.resume()
    }
    
    @objc
    func makeTransaction(paymentMethodNonce: String, merchantAccountID: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        NSLog("Creating a transaction with nonce: %@", paymentMethodNonce)
        
        guard var urlComponents = URLComponents(
            string: BraintreeDemoSettings.currentEnvironmentURLString + "/nonce/transaction"
        ) else { return }

        var queryItems = [URLQueryItem(name: "nonce", value: paymentMethodNonce)]
        
        if BraintreeDemoSettings.threeDSecureRequiredStatus == .required {
            queryItems += [URLQueryItem(name: "three_d_secure_required", value: "true")]
        } else if BraintreeDemoSettings.threeDSecureRequiredStatus == .optional {
            queryItems += [URLQueryItem(name: "three_d_secure_required", value: "false")]
        }
        
        if let id = merchantAccountID {
            queryItems += [URLQueryItem(name: "merchant_account_id", value: id)]
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let message = try? JSONDecoder().decode(TransactionResponse.self, from: data).message
            DispatchQueue.main.async { completion(message, nil) }
        }
        
        task.resume()
    }
}
