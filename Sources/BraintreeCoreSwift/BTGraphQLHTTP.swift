import Foundation

protocol Node: AnyObject {
    var childOrder: [String] { get set }
    var children: [String: Node] { get set }
    func toDictionary() -> [String: Any]
}

extension Node {
    
    func insert(_ node: Node, forKeyPath keyPath: [String]) {
        guard let firstKey = keyPath.first else { return }
        
        if keyPath.count == 1 {
            childOrder.append(firstKey)
            children[firstKey] = node
        } else {
            if children[firstKey] == nil {
                childOrder.append(firstKey)
                children[firstKey] = ParentNode(field: firstKey)
            }
            children[firstKey]!.insert(node, forKeyPath: Array(keyPath[1..<keyPath.count]))
        }
    }
}

class RootNode: Node {
    let message: String
    var childOrder: [String] = []
    var children: [String: Node] = [:]
    
    init(message: String) {
        self.message = message
    }
    
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = ["error": ["message": message ]]
        if !children.isEmpty {
            var fieldErrors: [[String: Any]] = []
            for key in childOrder {
                guard let child = children[key] else { continue }
                fieldErrors.append(child.toDictionary())
            }
            result["fieldErrors"] = fieldErrors
        }
        return result
    }
}

class ParentNode: Node {
    let field: String
    var childOrder: [String] = []
    var children: [String: Node] = [:]
    
    init(field: String) {
        self.field = field
    }
    
    func toDictionary() -> [String : Any] {
        var result: [String: Any] = ["field": field]
        if (!children.isEmpty) {
            var fieldErrors: [[String: Any]] = []
            for key in childOrder {
                guard let child = children[key] else { continue }
                fieldErrors.append(child.toDictionary())
            }
            result["fieldErrors"] = fieldErrors
        }
        return result
    }
}

class ChildNode: Node {
    let field: String
    let message: String
    let code: String?
    var childOrder: [String] = []
    var children: [String: Node] = [:]
    
    init(field: String, message: String, code: String?) {
        self.field = field
        self.message = message
        self.code = code
    }
    
    func toDictionary() -> [String : Any] {
        var result = ["field": field, "message": message]
        if let code = code {
            result["code"] = code
        }
        return result
    }
}

    
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
//            errorBody["error"] = ["message": "Input is invalid"]
            
            let rootNode = RootNode(message: "Input is invalid")
            
            var nodes: [String: Node] = [:]
            
            var errors: [[String: Any]] = []
            for errorJSON in body["errors"].asArray() ?? [] {
                guard var inputPath = errorJSON["extensions"]["inputPath"].asStringArray() else { continue }
                guard let field = inputPath.last else { continue }
                guard let message = errorJSON["message"].asString() else { continue }
                
                let code = errorJSON["extensions"]["legacyCode"].asString()
                
                // discard initial "input" key
                let keyPath = Array(inputPath[1..<inputPath.count])
                
                let childNode = ChildNode(field: field, message: message, code: code)
                rootNode.insert(childNode, forKeyPath: keyPath)
                
//
//                addErrorForInputPath(
//                    inputPath: Array(inputPath[1..<inputPath.count]),
//                    withGraphQLError: errorJSON,
//                    toArray: &errors
//                )
            }
            
            if rootNode.children.count > 0 {
//                errorBody["fieldErrors"] = errors
                errorBody = rootNode.toDictionary()
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
    
//    func addErrorForInputPath2(withGraphQLError errors: [BTJSON]) -> [String: Any]? {
//
////        let result = NSObject()
////        result.setValue(<#T##value: Any?##Any?#>, forKeyPath: <#T##String#>)
//
//        var errorMap: [String: [ErrorNode]] = [:]
//        for json in errors {
//            guard let inputPath = json["extensions"]["inputPath"].asStringArray() else { continue }
//            guard let field = inputPath.last else { continue }
//
//            // discard initial "input" value to get the error key path
//            let keyPath = Array(inputPath[1..<inputPath.count]).joined(separator: ".")
//
//            let extensions = json["extensions"].asSwiftDictionary()
//            let code = extensions?["legacyCode"] as? String
//            let message = json["message"].asString() ?? ""
//
//            var value = [
//                "field": field,
//                "message": message
//            ]
//
//
//            if errorMap[keyPath] == nil {
//                errorMap[keyPath] = []
//            }
//            errorMap[keyPath]!.append(ErrorNode(field: field, message: message, code: code))
//        }
//    }
    
    /// Walks through the input path recursively and adds field errors to a mutable array
    func addErrorForInputPath(
        inputPath: [String],
        withGraphQLError errorJSON: BTJSON,
        toArray errors: inout [[String: Any]]
    ) {
        guard let field: String = inputPath.first else { return }
        
        // Base case
        if inputPath.count == 1 {
            let extensions = errorJSON["extensions"].asSwiftDictionary()
            var errorsBody: [String: String] = [
                "field": field,
                "message": errorJSON["message"].asString() ?? ""
            ]

            if extensions?["legacyCode"] != nil {
                errorsBody["code"] = extensions?["legacyCode"] as? String
            }

            errors.append(errorsBody as [String: Any])
            return
        }
        
//        var nestedFieldError: [String: Any] = [:]

        // Find nested error that matches the field
        
//        for error in errors {
//            if error["field"] as? String == field {
//                nestedFieldError = error
//            }
//            break
//        }
        
        var fieldErrors: [[String:Any]]!
        
        if var nestedFieldError = errors.first(where: { $0["field"] as? String == field }) {
            fieldErrors = nestedFieldError["fieldErrors"] as? [[String: Any]]
            addErrorForInputPath(
                inputPath: Array(inputPath[1..<inputPath.count]),
                withGraphQLError: errorJSON,
                toArray: &fieldErrors
            )
            nestedFieldError["fieldErrors"] = fieldErrors
         } else {
            fieldErrors = []
             errors.append([
                "field": field,
                "fieldErrors": fieldErrors
            ])
             addErrorForInputPath(
                inputPath: Array(inputPath[1..<inputPath.count]),
                withGraphQLError: errorJSON,
                toArray: &fieldErrors
            )
        }
    }
}
    
