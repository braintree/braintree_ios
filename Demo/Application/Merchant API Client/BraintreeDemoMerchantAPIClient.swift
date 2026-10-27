import Foundation

class BraintreeDemoMerchantAPIClient: NSObject {
    
    private struct ClientToken: Codable {

        let clientToken: String
    }

    private struct TransactionResponse: Codable {

        let message: String
    }
    
    static let shared = BraintreeDemoMerchantAPIClient()
    
    private override init() {}
    
    func createCustomerAndFetchClientToken(
        merchantAccountID: String? = nil,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard var urlComponents = URLComponents(string: BraintreeDemoSettings.currentEnvironmentURLString + "/client_token") else { return }

        var queryItems: [URLQueryItem] = []

        if BraintreeDemoSettings.customerPresent {
            if let id = BraintreeDemoSettings.customerIdentifier, !id.isEmpty {
                queryItems.append(URLQueryItem(name: "customer_id", value: id))
            } else {
                queryItems.append(URLQueryItem(name: "customer_id", value: UUID().uuidString))
            }
        }

        if let merchantAccountID {
            queryItems.append(URLQueryItem(name: "merchant_account_id", value: merchantAccountID))
        }

        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else { return }

        NSLog("[client_token] Requesting: %@", url.absoluteString)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                NSLog("[client_token] Response status: %d", httpResponse.statusCode)
            }

            guard let data = data, error == nil else {
                NSLog("[client_token] Request failed: %@", error?.localizedDescription ?? "unknown error")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            NSLog("[client_token] Raw response body: %@", String(data: data, encoding: .utf8) ?? "<non-utf8 data>")

            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let clientToken = try? jsonDecoder.decode(ClientToken.self, from: data).clientToken

            if let clientToken, let decoded = Data(base64Encoded: clientToken) {
                NSLog("[client_token] Decoded client token: %@", String(data: decoded, encoding: .utf8) ?? "<non-utf8 data>")
            } else {
                NSLog("[client_token] Failed to decode client token or token is nil")
            }

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
}
