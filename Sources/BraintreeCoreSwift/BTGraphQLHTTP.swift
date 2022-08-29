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
        
        let components = URLComponents(string: self.baseURL.absoluteString)
        let headers = [
            "User-Agent": self.userAgentString(),
            "Braintree-Version": BTCoreConstants.graphQLVersion,
            "Authorization": "Bearer \(authorization)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        var request: URLRequest
    
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            // TODO: don't force unwrap
            request = URLRequest(url: components!.url!)
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
            self.callCompletionAsync(
                with: completion,
                body: nil,
                response: response as? HTTPURLResponse,
                error: error
            )
            return
        }
        
        guard let data = data else {
            let error = NSError(
                domain: BTHTTPError.domain,
                code: BTHTTPErrorCode.unknown.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred with the HTTP request."]
            )

            callCompletionAsync(
                with: completion,
                body: nil,
                response: response as? HTTPURLResponse,
                error: error
            )
            return
        }

        let json = try? JSONSerialization.jsonObject(with: data)
        let body = BTJSON(value: json)

        // Success case
        if let _ = body.asDictionary(), body["errors"].asArray() == nil {
            callCompletionAsync(
                with: completion,
                body: body,
                response: response as? HTTPURLResponse,
                error: nil
            )
            return
        }
        
        // Error case
        parseErrors(body: body, response: response!) { errorJSON, error in
            self.callCompletionAsync(
                with: completion,
                body: BTJSON(value: errorJSON),
                response: response as? HTTPURLResponse,
                error: error
            )
        }
    }
    
    func parseErrors(body: BTJSON, response: URLResponse, completion: @escaping ([String: Any]?, NSError?) -> Void) {
        let errorJSON = body["errors"][0]
        let errorType = errorJSON["extensions"]["errorType"].asString()
        var statusCode = 0
        var errorCode = BTHTTPErrorCode.unknown
        var errorBody = [String: Any]()
        
        if let errorType = errorType,
            errorType == "user_error" {
            statusCode = 422
            errorCode = .clientError
            errorBody["error"] = ["message": "Input is invalid"]
            
            var errors = [[String: Any]]()
            for error in body["errors"].asArray()! {
                guard let inputPath = error["extensions"]["inputPath"].asStringArray() else {
                    continue
                }

                addErrorForInputPath(
                    inputPath: Array(inputPath[1..<inputPath.count]),
                    withGraphQLError: error,
                    toArray: &errors
                )
            }
            if errors.count > 0 {
                errorBody["fieldErrors"] = errors
            }
        } else if let errorType = errorType,
                errorType == "developer_error" {
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
        
        let httpResponse = response as! HTTPURLResponse
        
        let nestedErrorResponse = HTTPURLResponse(
            url: response.url!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: httpResponse.allHeaderFields as? [String: String]
        )
        
        let error = NSError(
            domain: BTHTTPError.domain,
            code: errorCode.rawValue,
            userInfo: [
                BTHTTPError.urlResponseKey: nestedErrorResponse as Any,
                BTHTTPError.jsonResponseBodyKey: errorBody
            ]
        )

        completion(errorBody, error)
    }

    /// Walks through the input path recursively and adds field errors to a mutable array
    func addErrorForInputPath(
        inputPath: [String],
        withGraphQLError errorJSON: BTJSON,
        toArray errors: inout [[String: Any]]
    ) {
        guard let field = inputPath.first else { return }
        
        // Base case
        if inputPath.count == 1 {
            let extensions = errorJSON["extensions"].asSwiftDictionary()
            let errorsBody = [
                "field": field,
                "message": errorJSON["message"],
                "code": extensions?["legacyCode"]
            ]

            errors.append(errorsBody as [String: Any])
            return
        }
        
        var nestedFieldError: [String: Any]? = [:]
        let nestedInputPath = Array(inputPath[1..<inputPath.count])
        // Find nested error that matches the field
        for error in errors {
            if error["field"] as? String == field {
                nestedFieldError = error
            }
        }
        
        if nestedFieldError == nil {
            nestedFieldError = [
                "field": field,
                "fieldErrors": NSMutableArray()
            ]

            errors.append(nestedFieldError ?? [:])
        }

        addErrorForInputPath(
            inputPath: Array(nestedInputPath[1..<nestedInputPath.count]),
            withGraphQLError: errorJSON,
            toArray: &errors
        )
    }
}
