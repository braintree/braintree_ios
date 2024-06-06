import Foundation

class BTGraphQLHTTP: BTHTTP {

    typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Properties

    private let exceptionName: NSExceptionName = NSExceptionName("")

    // MARK: - Overrides

    override func get(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, completion: @escaping RequestCompletion) {
        NSException(name: exceptionName, reason: "GET is unsupported").raise()
    }

    override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", configuration: configuration, parameters: parameters, completion: completion)
    }

    // MARK: - Internal methods
    
    func httpRequest(
        method: String,
        configuration: BTConfiguration? = nil,
        parameters: [String: Any]? = [:],
        completion: @escaping RequestCompletion
    ) {
        var errorUserInfo: [String: Any] = [:]

        guard let baseURL = configuration?.graphQLURL ?? customBaseURL,
            !baseURL.absoluteString.isEmpty else {
            errorUserInfo["method"] = method
            errorUserInfo["parameters"] = parameters
            completion(nil, nil, BTHTTPError.missingBaseURL(errorUserInfo))
            return
        }
        
        guard let components = URLComponents(string: baseURL.absoluteString) else {
            completion(nil, nil, BTHTTPError.urlStringInvalid)
            return
        }

        guard let urlFromComponents = components.url else {
            completion(nil, nil, BTHTTPError.urlStringInvalid)
            return
        }

        let headers = [
            "User-Agent": userAgentString,
            "Braintree-Version": BTCoreConstants.graphQLVersion,
            "Authorization": "Bearer \(authorization.bearer)",
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        var request: URLRequest
    
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            request = URLRequest(url: urlFromComponents)
            request.httpBody = bodyData
            request.allHTTPHeaderFields = headers
            request.httpMethod = method

            // Perform the actual request
            session.dataTask(with: request) { [weak self] data, response, error in
                guard let self else {
                    completion(nil, nil, BTHTTPError.deallocated("BTGraphQLHTTP"))
                    return
                }

                handleRequestCompletion(data: data, response: response, error: error, completion: completion)
            }.resume()
        } catch {
            completion(nil, nil, error)
        }
    }

    func handleRequestCompletion(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: RequestCompletion?
    ) {
        guard let completion = completion else { return }

        if let error = error {
            callCompletionAsync(with: completion, body: nil, response: response as? HTTPURLResponse, error: error)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            callCompletionAsync(with: completion, body: nil, response: nil, error: BTHTTPError.httpResponseInvalid)
            return
        }
        
        guard let data = data else {
            callCompletionAsync(with: completion, body: nil, response: httpResponse, error: BTHTTPError.unknown)
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
    
    func parseErrors(body: BTJSON, response: HTTPURLResponse, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let errorJSON = body["errors"][0]
        let errorType = errorJSON["extensions"]["errorType"].asString()

        var statusCode = 0
        var error: BTHTTPError = .unknown
        var errorBody: [String: Any] = [:]

        if let errorType, errorType == "user_error" {
            statusCode = 422
            errorBody = parseGraphQLError(fromJSON: body)
            error = .clientError(errorBody)
        } else if let errorType, errorType == "developer_error" {
            statusCode = 403

            if let message = errorJSON["message"].asString() {
                errorBody["error"] = ["message": message]
            }
            error = .clientError(errorBody)
        } else if body["extensions"].asDictionary() != nil, let errorMessage = errorJSON["message"].asString() {
            statusCode = 403
            errorBody["error"] = ["message": errorMessage]
            error = .clientError(errorBody)
        } else {
            statusCode = 500
            errorBody["error"] = ["message": "An unexpected error occurred"]
            error = .serverError(errorBody)
        }
        
        let nestedErrorResponse = createHTTPResponse(response: response, statusCode: statusCode)
        let nestedGraphQLError = NSError(
            domain: BTHTTPError.errorDomain,
            code: error.errorCode,
            userInfo: [
                BTCoreConstants.urlResponseKey: nestedErrorResponse as Any,
                BTCoreConstants.jsonResponseBodyKey: BTJSON(value: errorBody)
            ]
        )

        completion(errorBody, nestedGraphQLError)
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
            guard let inputPath = errorJSON["extensions"]["inputPath"].asStringArray() else {
                if errorJSON["extensions"]["errorClass"].asString() == "VALIDATION" {
                    if let message = errorJSON["message"].asString() {
                        return BTGraphQLErrorTree(message: message).toDictionary()
                    }
                }
                continue
            }
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
