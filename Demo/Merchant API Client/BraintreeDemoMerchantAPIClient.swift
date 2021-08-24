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
            if let id = BraintreeDemoSettings.customerIdentifier, id.count > 0 {
                urlComponents.queryItems = [URLQueryItem(name: "customer_id", value: id)]
            } else {
                urlComponents.queryItems = [URLQueryItem(name: "customer_id", value: UUID().uuidString)]
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
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

    // NOTE: - The only feature that currently works with a PP ID Token is Card Tokenization.
    @objc
    func fetchPayPalIDToken(completion: @escaping ((String?, Error?) -> Void)) {
        let ppcpSampleMerchantServerURL = (BraintreeDemoSettings.currentEnvironment == .production
            ? "https://ppcp-sample-merchant-prod.herokuapp.com"
            : "https://ppcp-sample-merchant-sand.herokuapp.com")
        
        guard let urlComponents = URLComponents(string: ppcpSampleMerchantServerURL + "/id-token?countryCode=US") else { return }

        let task = URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let token = json["id_token"]
                    DispatchQueue.main.async { completion(token as? String, nil) }
                }
            } catch let error as NSError {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        task.resume()
    }
    
    @objc
    func makeTransaction(paymentMethodNonce: String, merchantAccountId: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        NSLog("Creating a transaction with nonce: %@", paymentMethodNonce)
        
        guard var urlComponents = URLComponents(string: BraintreeDemoSettings.currentEnvironmentURLString + "/nonce/transaction") else { return }
        
        var queryItems = [URLQueryItem(name: "nonce", value: paymentMethodNonce)]
        
        if (BraintreeDemoSettings.threeDSecureRequiredStatus == .required) {
            queryItems += [URLQueryItem(name: "three_d_secure_required", value: "true")]
        } else if (BraintreeDemoSettings.threeDSecureRequiredStatus == .optional) {
            queryItems += [URLQueryItem(name: "three_d_secure_required", value: "false")]
        }
        
        if let id = merchantAccountId {
            queryItems += [URLQueryItem(name: "merchant_account_id", value: id)]
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
