import Foundation

@objcMembers public class BTGraphQLHTTPSwift: BTHTTPSwift {

    // MARK: - Overrides

    public override func get(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        fatalError("GET is unsupported")
    }

    public override func get(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        fatalError("GET is unsupported")
    }

    public override func post(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        self.httpRequest(method: "POST", parameters: nil, completion: completion)
    }

    public override func post(_ path: String, parameters: NSDictionary? = nil, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        self.httpRequest(method: "POST", parameters: nil, completion: completion)
    }

    public override func put(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        fatalError("PUT is unsupported")
    }

    public override func put(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        fatalError("PUT is unsupported")
    }

    public override func delete(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        fatalError("DELETE is unsupported")
    }

    public override func delete(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?) {
        fatalError("DELETE is unsupported")
    }

    // MARK: - Internal methods
    
    func httpRequest(
        method: String,
        parameters: NSDictionary? = [:],
        completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?
    ) {
        var errorUserInfo: [String: Any] = [:]

        if self.baseURL.absoluteString.isEmpty || self.baseURL.absoluteString == "" {
            errorUserInfo["method"] = method
            errorUserInfo["parameters"] = parameters
            let error = self.constructError(code: .missingBaseURL, userInfo: errorUserInfo)
            // TODO: why not use callCompletion?
            completion?(nil, nil, error)
            return
        }
        
        let components = URLComponents(string: self.baseURL.absoluteString)
        let headers = [
            "User-Agent": self.userAgentString(),
            "Braintree-Version": BTCoreConstants.graphQLVersion,
            "Authorization": "Bearer \(self.authorizationFingerprint ?? self.tokenizationKey)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        var request: URLRequest
    
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: parameters as Any)
            // TODO: don't force unwrap
            request = URLRequest(url: components!.url!)
            request.httpBody = bodyData
            request.allHTTPHeaderFields = headers
            request.httpMethod = method
            
            let task: URLSessionTask? = self.session?.dataTask(with: request) { [weak self] data, response, error in
                self?.handleRequestCompletion(data: data, response: response, error: error, completion: completion)
            }
            task?.resume()
        } catch {
            completion?(nil, nil, error)
        }
    }

    public func handleRequestCompletion(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)?
    ) {
        // TODO: implementation
    }

    /// Walks through the input path recursively and adds field errors to a mutable array
    func addErrorForInputPath(inputPath: [String], withGraphQLError errorJSON: [String: Any], toArray errors:[[String: Any]]) {
        // TODO: implementation
    }
}
