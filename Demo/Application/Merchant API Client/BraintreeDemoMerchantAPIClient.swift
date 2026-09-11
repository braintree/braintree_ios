import Foundation

class BraintreeDemoMerchantAPIClient: NSObject {
    
    private struct ClientToken: Codable {

        let clientToken: String
    }

    private struct TransactionResponse: Codable {

        let message: String
    }
    
    struct PaymentActionResponse: Codable {

        let clientToken: String
        let paymentAction: PaymentActionDetail
    }

    struct PaymentActionDetail: Codable {

        let id: String
        let status: String
    }
    
    static let shared = BraintreeDemoMerchantAPIClient()
    
    private override init() {}
    
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
    
    func fetchPaymentActionClientToken(
        amount: String,
        merchantAccountID: String,
        confirmationMethod: String = "AUTOMATIC",
        captureMethod: String = "AUTOMATIC",
        completion: @escaping (PaymentActionResponse?, Error?) -> Void
    ) {
        guard var urlComponents = URLComponents(string: "https://braintree-sample-merchant.herokuapp.com/create_payment_action") else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "amount", value: amount),
            URLQueryItem(name: "merchant_account_id", value: merchantAccountID),
            URLQueryItem(name: "confirmation_method", value: confirmationMethod),
            URLQueryItem(name: "capture_method", value: captureMethod)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try? jsonDecoder.decode(PaymentActionResponse.self, from: data)
            DispatchQueue.main.async { completion(response, nil) }
        }
        task.resume()
    }
}
