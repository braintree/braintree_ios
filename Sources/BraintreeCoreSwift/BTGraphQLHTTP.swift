import Foundation

@objcMembers public class BTGraphQLHTTPSwift: BTHTTPSwift {
    
    public func handleRequestCompletion(data: Data?, response: URLResponse?, error: Error?, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        
    }
    
    public override func get(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        fatalError("GET is unsupported")
    }
    
    public override func get(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        fatalError("GET is unsupported")
    }
    
    public override func post(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        self.httpRequest(method: "POST", parameters: nil, completion: completion)
    }
    
    // MARK: - Internal
    
    func httpRequest(method: String, parameters: NSDictionary?, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        if self.baseURL.absoluteString == "" {
            var errorUserInfo = [String:Any]()
            errorUserInfo["method"] = method
            errorUserInfo["parameters"] = parameters
            let error = NSError(domain: BTHTTPError.domain,
                                code: BTHTTPErrorCode.missingBaseURL.rawValue,
                                userInfo: errorUserInfo)
            // TODO: why not use callCompletion?
            completion?(nil, nil, error)
            return
        }
        
        let components = URLComponents(string: self.baseURL.absoluteString)
        var headers = ["User-Agent": self.userAgentString(),
                       "Braintree-Version": "FAKE", // TODO: FIX WHAT???
                       "Authorization": "Bearer \(self.authorizationFingerprint ?? self.tokenizationKey)",
                       "Content-Type": "application/json; charset=utf-8"
        ]
        
        var request: URLRequest
    
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: parameters as Any)
            request = URLRequest(url: components!.url!)
            request.httpBody = bodyData
            request.allHTTPHeaderFields = headers
            request.httpMethod = method
            
            self.session?.dataTask(with: request) {
                data, response, error in
                self.handleRequestCompletion(data: data, response: response, error: error, completion: completion)
            }.resume()
        } catch {
            completion?(nil, nil, error)
        }
        
        
    }
}
