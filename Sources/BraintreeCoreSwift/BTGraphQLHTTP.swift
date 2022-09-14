import Foundation

@objcMembers public class BTGraphQLHTTPSwift: BTHTTPSwift {

    public typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Properties

    private let exceptionName: NSExceptionName = NSExceptionName("")

    // MARK: - Overrides

    public override func get(_ path: String, completion: @escaping RequestCompletion) {
        NSException(name: exceptionName, reason: "GET is unsupported").raise()
    }

    public override func get(_ path: String, parameters: NSDictionary? = nil, completion: RequestCompletion?) {
        NSException(name: exceptionName, reason: "GET is unsupported").raise()
    }

    public override func post(_ path: String, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", parameters: nil, completion: completion)
    }

    public override func post(_ path: String, parameters: NSDictionary? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", parameters: parameters, completion: completion)
    }

    public override func put(_ path: String, completion: @escaping RequestCompletion) {
        NSException(name: exceptionName, reason: "PUT is unsupported").raise()
    }

    public override func put(_ path: String, parameters: NSDictionary? = nil, completion: RequestCompletion?) {
        NSException(name: exceptionName, reason: "PUT is unsupported").raise()
    }

    public override func delete(_ path: String, completion: @escaping RequestCompletion) {
        NSException(name: exceptionName, reason: "DELETE is unsupported").raise()
    }

    public override func delete(_ path: String, parameters: NSDictionary? = nil, completion: RequestCompletion?) {
        NSException(name: exceptionName, reason: "DELETE is unsupported").raise()
    }

    // MARK: - Internal methods
    
    func httpRequest(
        method: String,
        parameters: NSDictionary? = [:],
        completion: RequestCompletion?
    ) {
        var errorUserInfo: [String: Any] = [:]

        if self.baseURL.absoluteString.isEmpty || self.baseURL.absoluteString == "" {
            errorUserInfo["method"] = method
            errorUserInfo["parameters"] = parameters
            let error = Self.constructError(code: .missingBaseURL, userInfo: errorUserInfo)
            // TODO: why not use callCompletion?
            completion?(nil, nil, error)
            return
        }
        
        let authorization: String
        switch self.clientAuthorization {
        case .authorizationFingerprint(let fingerprint):
            authorization = fingerprint
        case .tokenizationKey(let key):
            authorization = key
        case .none:
            authorization = "" 
        }
        
        guard let components = URLComponents(string: self.baseURL.absoluteString) else {
            let error = Self.constructError(
                code: .urlStringInvalid,
                userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
            )
            completion?(nil, nil, error)
            return
        }

        guard let urlFromComponents = components.url else {
            let error = Self.constructError(
                code: .urlStringInvalid,
                userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
            )
            completion?(nil, nil, error)
            return
        }

        let headers = [
            "User-Agent": self.userAgentString(),
            "Braintree-Version": BTCoreConstants.graphQLVersion,
            "Authorization": "Bearer \(authorization)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        var request: URLRequest
    
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            request = URLRequest(url: urlFromComponents)
            request.httpBody = bodyData
            request.allHTTPHeaderFields = headers
            request.httpMethod = method
            
            let task: URLSessionTask = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                self.handleRequestCompletion(data: data, response: response, error: error, completion: completion)
            }

            task.resume()
        } catch {
            completion?(nil, nil, error)
        }
    }

    @objc(handleRequestCompletion:response:error:completionBlock:)
    public func handleRequestCompletion(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: RequestCompletion?
    ) {
        guard let completion = completion else {
            return
        }

        if let error = error {
            callCompletionAsync(with: completion, body: nil, response: response as? HTTPURLResponse, error: error)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            let error = Self.constructError(
                code: .httpResponseInvalid,
                userInfo: [NSLocalizedDescriptionKey : "URLResponse was missing on invalid."]
            )
            callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            return
        }
        
        guard let data = data else {
            let error = NSError(
                domain: BTHTTPError.domain,
                code: BTHTTPErrorCode.unknown.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred with the HTTP request."]
            )

            callCompletionAsync(with: completion, body: nil, response: httpResponse, error: error)
            return
        }

        let json = try? JSONSerialization.jsonObject(with: data)
        let body = BTJSON(value: json)

        // Success case
        if let _ = body.asDictionary(), body["errors"].asArray() == nil {
            callCompletionAsync(with: completion, body: body, response: httpResponse, error: nil)
            return
        }
        
        // Error case
        parseErrors(body: body, response: httpResponse) { errorJSON, error in
            self.callCompletionAsync(
                with: completion,
                body: BTJSON(value: errorJSON),
                response: httpResponse,
                error: error
            )
        }
    }
    
    func parseErrors(body: BTJSON, response: HTTPURLResponse, completion: @escaping ([String: Any]?, NSError?) -> Void) {
        let errorJSON = body["errors"][0]
        let errorType = errorJSON["extensions"]["errorType"].asString()

        var statusCode = 0
        var errorCode = BTHTTPErrorCode.unknown
        var errorBody: [String: Any] = [:]
        
        if let errorType = errorType, errorType == "user_error" {
            statusCode = 422
            errorCode = .clientError
            errorBody = parseGraphQLError(fromJSON: body)
            
        } else if let errorType = errorType, errorType == "developer_error" {
            statusCode = 403
            errorCode = .clientError
            
            if let message = errorJSON["message"].asString() {
                errorBody["error"] = ["message": message]
            }
        } else {
            statusCode = 500
            errorCode = .serverError
            errorBody["error"] = ["message": "An unexpected error occurred"]
        }
        
        let nestedErrorResponse = createHTTPResponse(response: response, statusCode: statusCode)
        
        let error = NSError(
            domain: BTHTTPError.domain,
            code: errorCode.rawValue,
            userInfo: [
                BTHTTPError.urlResponseKey: nestedErrorResponse as Any,
                BTHTTPError.jsonResponseBodyKey: BTJSON(value: errorBody)
            ]
        )

        completion(errorBody, error)
    }

    func createHTTPResponse(response: URLResponse, statusCode: Int) -> HTTPURLResponse? {
        if let httpResponse = response as? HTTPURLResponse, let url = response.url {
            return HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: httpResponse.allHeaderFields as? [String: String]
            )
        }
        return nil
    }
    
    func parseGraphQLError(fromJSON body: BTJSON) -> [String: Any] {
        let errorTree = BTGraphQLErrorTree(message: "Input is invalid")
        for errorJSON in body["errors"].asArray() ?? [] {
            guard let inputPath = errorJSON["extensions"]["inputPath"].asStringArray() else { continue }
            guard let field = inputPath.last else { continue }
            guard let message = errorJSON["message"].asString() else { continue }
            
            let code = errorJSON["extensions"]["legacyCode"].asString()
            
            // discard initial "input" from key path
            let keyPath = Array(inputPath[1..<inputPath.count])
            
            let errorNode = BTGraphQLSingleErrorNode(field: field, message: message, code: code)
            errorTree.insert(errorNode, atKeyPath: keyPath)
        }
        return errorTree.toDictionary()
    }
}
