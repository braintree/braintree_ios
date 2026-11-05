import Foundation

class BraintreeDemoMerchantAPIClient: NSObject {
    
    private struct ClientToken: Codable {

        let clientToken: String
    }

    private struct TransactionResponse: Codable {

        let message: String
    }

    private struct VaultResponse: Codable {

        let message: String
        let token: String?
    }
    
    static let shared = BraintreeDemoMerchantAPIClient()
    
    private override init() {}
    
    func createCustomerAndFetchClientToken(completion: @escaping (String?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: BraintreeDemoSettings.currentEnvironmentURLString + "/client_token") else { return }
        
        var queryItems: [URLQueryItem] = []

        if BraintreeDemoSettings.customerPresent {
            if let id = BraintreeDemoSettings.customerIdentifier, !id.isEmpty {
                queryItems.append(URLQueryItem(name: "customer_id", value: id))
            } else {
                queryItems.append(URLQueryItem(name: "customer_id", value: UUID().uuidString))
            }
        }

        if let paymentMethodToken = BraintreeDemoSettings.paymentMethodToken, !paymentMethodToken.isEmpty {
            queryItems.append(URLQueryItem(name: "preferred_payment_method_token", value: paymentMethodToken))
        }

        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
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

    func vaultPaymentMethod(paymentMethodNonce: String, completion: @escaping (_ paymentMethodToken: String?, _ message: String?) -> Void) {
        let customerURLString = BraintreeDemoSettings.currentEnvironmentURLString + "/customers/" + UUID().uuidString

        guard
            let customerURL = URL(string: customerURLString),
            var vaultURLComponents = URLComponents(string: customerURLString + "/vault")
        else { return }

        vaultURLComponents.queryItems = [URLQueryItem(name: "nonce", value: paymentMethodNonce)]

        guard let vaultURL = vaultURLComponents.url else { return }

        var customerRequest = URLRequest(url: customerURL)
        customerRequest.httpMethod = "PUT"

        let customerTask = URLSession.shared.dataTask(with: customerRequest) { _, _, error in
            if let error {
                DispatchQueue.main.async { completion(nil, error.localizedDescription) }
                return
            }

            var vaultRequest = URLRequest(url: vaultURL)
            vaultRequest.httpMethod = "POST"

            let vaultTask = URLSession.shared.dataTask(with: vaultRequest) { data, _, error in
                guard let data, error == nil else {
                    DispatchQueue.main.async { completion(nil, error?.localizedDescription) }
                    return
                }

                let response = try? JSONDecoder().decode(VaultResponse.self, from: data)
                DispatchQueue.main.async { completion(response?.token, response?.message) }
            }

            vaultTask.resume()
        }

        customerTask.resume()
    }
}
