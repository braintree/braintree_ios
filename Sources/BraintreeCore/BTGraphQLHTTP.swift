import Foundation

class BTGraphQLHTTP: BTHTTP {

    // MARK: - Overrides
    
    // TODO: Remove this version of get once BTAPIClient converted to async/await
    override func get(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        completion: @escaping RequestCompletion
    ) {
        callCompletionAsync(with: completion, body: nil, response: nil, error: BTGraphQLHTTPError.unsupportedOperation)
    }
    
    override func get(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        throw BTGraphQLHTTPError.unsupportedOperation
    }

    // TODO: Remove this version of post once BTAPIClient converted to async/await
    override func post(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil,
        completion: @escaping RequestCompletion
    ) {
        Task { [self] in
            let result = await httpRequestReturningResult(method: "POST", configuration: configuration, parameters: parameters)
            callCompletionAsync(with: completion, body: result.body, response: result.response, error: result.error)
        }
    }

    override func post(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        try await httpRequest(method: "POST", configuration: configuration, parameters: parameters)
    }

    // MARK: - Internal methods

    func httpRequest(
        method: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        let result = await httpRequestReturningResult(method: method, configuration: configuration, parameters: parameters)
        if let error = result.error {
            throw error
        }
        return (result.body, result.response)
    }

    // MARK: - Private methods

    private func httpRequestReturningResult(
        method: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil
    ) async -> BTGraphQLRequestResult {
        var errorUserInfo: [String: Any] = [:]

        guard
            let baseURL = configuration?.graphQLURL ?? customBaseURL,
            !baseURL.absoluteString.isEmpty
        else {
            errorUserInfo["method"] = method
            errorUserInfo["parameters"] = parameters
            return BTGraphQLRequestResult(body: nil, response: nil, error: BTHTTPError.missingBaseURL(errorUserInfo))
        }

        guard let components = URLComponents(string: baseURL.absoluteString) else {
            return BTGraphQLRequestResult(body: nil, response: nil, error: BTHTTPError.urlStringInvalid)
        }

        guard let urlFromComponents = components.url else {
            return BTGraphQLRequestResult(body: nil, response: nil, error: BTHTTPError.urlStringInvalid)
        }

        let headers = [
            "User-Agent": userAgentString,
            "Braintree-Version": BTCoreConstants.graphQLVersion,
            "Authorization": "Bearer \(authorization.bearer)",
            "Content-Type": "application/json; charset=utf-8"
        ]

        var request: URLRequest

        // swiftlint:disable:next redundant_optional_initialization
        var bodyData: Data? = nil
        if let parameters {
            bodyData = try? JSONEncoder().encode(parameters)
        }

        request = URLRequest(url: urlFromComponents)
        request.httpBody = bodyData
        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        // Perform the actual request
        do {
            let (data, response) = try await session.data(for: request)
            return handleRequestCompletionReturningResult(data: data, response: response, error: nil)
        } catch {
            return handleRequestCompletionReturningResult(data: nil, response: nil, error: error)
        }
    }

    private func handleRequestCompletionReturningResult(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> BTGraphQLRequestResult {
        if let error = error {
            return BTGraphQLRequestResult(body: nil, response: response as? HTTPURLResponse, error: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return BTGraphQLRequestResult(body: nil, response: nil, error: BTHTTPError.httpResponseInvalid)
        }

        guard let data = data else {
            return BTGraphQLRequestResult(body: nil, response: httpResponse, error: BTHTTPError.unknown)
        }

        let json = try? JSONSerialization.jsonObject(with: data)
        let body = BTJSON(value: json)

        // Success case
        if body.asDictionary() != nil, body["errors"].asArray() == nil {
            return BTGraphQLRequestResult(body: body, response: httpResponse, error: nil)
        }

        // Error case
        let (errorJSON, parseError) = parseErrors(body: body, response: httpResponse)
        return BTGraphQLRequestResult(body: BTJSON(value: errorJSON), response: httpResponse, error: parseError)
    }
    
    func parseErrors(body: BTJSON, response: HTTPURLResponse) -> ([String: Any]?, Error?) {
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

        return (errorBody, nestedGraphQLError)
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
