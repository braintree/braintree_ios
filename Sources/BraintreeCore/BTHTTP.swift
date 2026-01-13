import Foundation
import Security

// swiftlint:disable type_body_length file_length
/// Performs HTTP methods on the Braintree Client API
class BTHTTP: NSObject, URLSessionTaskDelegate {

    typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Internal Properties

    /// An array of pinned certificates, each a Data instance consisting of DER encoded x509 certificates
    let pinnedCertificates: [Data] = BTAPIPinnedCertificates.trustedCertificates()

    /// DispatchQueue on which asynchronous code will be executed. Defaults to `DispatchQueue.main`.
    var dispatchQueue = DispatchQueue.main
    
    /// A URL set to override the URLs derived from the ClientAuthorization or BTConfiguration response
    let customBaseURL: URL?
    
    let authorization: ClientAuthorization
    
    weak var networkTimingDelegate: BTHTTPNetworkTiming?

    /// Session exposed for testing
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        let delegateQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }()

    var defaultHeaders: [String: String] {
        [
            "User-Agent": userAgentString,
            "Accept": acceptString,
            "Accept-Language": acceptLanguageString
        ]
    }

    var userAgentString: String {
        "Braintree/iOS/\(BTCoreConstants.braintreeSDKVersion)"
    }

    var acceptString: String {
        "application/json"
    }

    var acceptLanguageString: String {
        "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "US")"
    }
    
    // MARK: - Internal Initializers
    
    /// Initialize `BTHTTP` with an Authorization credential
    /// - Parameters:
    ///   - authorization: a CilentToken or TokenizationKey
    ///   - customBaseURL: an optional baseURL override
    required init(authorization: ClientAuthorization, customBaseURL: URL? = nil) {
        self.authorization = authorization
        self.customBaseURL = customBaseURL
    }

    // MARK: - HTTP Methods

    func get(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: .get, path: path, configuration: configuration, parameters: parameters, completion: completion)
    }
    
    func get(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        try await httpRequest(
            method: .get,
            path: path,
            configuration: configuration,
            parameters: parameters
        )
    }
    
    func post(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil,
        completion: @escaping RequestCompletion
    ) {
        if authorization.type == .invalidAuthorization {
            completion(nil, nil, BTAPIClientError.invalidAuthorization(authorization.originalValue))
            return
        }
        
        httpRequest(
            method: .post,
            path: path,
            configuration: configuration,
            parameters: parameters,
            headers: headers,
            completion: completion
        )
    }
    
    func post(
        _ path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        try await httpRequest(
            method: .post,
            path: path,
            configuration: configuration,
            parameters: parameters,
            headers: headers
        )
    }

    // MARK: - HTTP Method Helpers

    // TODO: Remove once code calling completion handler version is removed.
    func httpRequest(
        method: BTHTTPMethod,
        path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil,
        completion: RequestCompletion?
    ) {
        guard let completion else { return }

        Task { [weak self] in
            guard let self else {
                DispatchQueue.main.async {
                    completion(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                }
                return
            }

            do {
                let (json, httpResponse) = try await httpRequest(
                    method: method,
                    path: path,
                    configuration: configuration,
                    parameters: parameters,
                    headers: headers
                )
                let jsonDict = json.asDictionary() as? [String: Any]
                let jsonValue = json.value
                let capturedResponse = httpResponse
                self.dispatchQueue.async {
                    let reconstructedJSON = jsonDict.map { BTJSON(value: $0) } ?? BTJSON(value: jsonValue)
                    completion(reconstructedJSON, capturedResponse, nil)
                }
            } catch {
                let bodyFromError = (error as NSError).userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
                let bodyDict = bodyFromError?.asDictionary() as? [String: Any]
                let response = (error as NSError).userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                let capturedError = error

                self.dispatchQueue.async {
                    let reconstructedBody = bodyDict.map { BTJSON(value: $0) }
                    completion(reconstructedBody, response, capturedError)
                }
            }
        }
    }
    
    func httpRequest(
        method: BTHTTPMethod,
        path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> (BTJSON, HTTPURLResponse) {
        let request = try createRequest(
            method: method,
            path: path,
            configuration: configuration,
            parameters: parameters,
            headers: headers
        )
        let (data, response) = try await session.data(for: request)
        return try handleRequestCompletion(data: data, request: request, response: response)
    }

    func createRequest(
        method: BTHTTPMethod,
        path: String,
        configuration: BTConfiguration? = nil,
        parameters: Encodable? = nil,
        headers: [String: String]? = [:]
    ) throws -> URLRequest {
        var fullPathURL: URL
        if let customBaseURL {
            fullPathURL = customBaseURL.appendingPathComponent(path)
        } else {
            fullPathURL = configuration?.clientAPIURL?.appendingPathComponent(path) ?? authorization.configURL
        }

        if fullPathURL.absoluteString.isEmpty {
            var errorUserInfo: [String: Any] = [:]
            errorUserInfo["method"] = method.rawValue
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            throw BTHTTPError.missingBaseURL(errorUserInfo)
        }
        
        var mutableParameters = NSMutableDictionary()
        if let parameters {
            let encodedData = try JSONEncoder().encode(parameters)
            if let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
                mutableParameters = NSMutableDictionary(dictionary: jsonObject)
            }
        }
        
        // TODO: - Investigate for parity on JS and Android
        // JIRA - DTBTSDK-2682
        if authorization.type == .clientToken, !fullPathURL.isPayPalURL {
            mutableParameters["authorization_fingerprint"] = authorization.bearer
        }

        return try buildHTTPRequest(
            method: method,
            url: fullPathURL,
            parameters: mutableParameters,
            headers: headers
        )
    }

    func buildHTTPRequest(
        method: BTHTTPMethod,
        url: URL,
        parameters: NSMutableDictionary? = [:],
        headers additionalHeaders: [String: String]? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(string: url.absoluteString) else {
            throw BTHTTPError.urlStringInvalid
        }
        
        var headers: [String: String] = defaultHeaders
        var request: URLRequest
        
        if url.isPayPalURL {
            headers = [:]
            if authorization.type == .clientToken {
                headers["Authorization"] = "Bearer \(authorization.bearer)"
            }
        } else {
            headers = defaultHeaders
            if authorization.type == .tokenizationKey {
                headers["Client-Key"] = authorization.bearer
            }
        }
        
        if let additionalHeaders {
            headers = headers.merging(additionalHeaders) { $1 }
        }
        
        if method == .get || method == .delete {
            components.percentEncodedQuery = BTURLUtils.queryString(from: parameters ?? [:])
            
            guard let urlFromComponents = components.url else {
                throw BTHTTPError.urlStringInvalid
            }
            
            request = URLRequest(url: urlFromComponents)
        } else {
            guard let urlFromComponents = components.url else {
                throw BTHTTPError.urlStringInvalid
            }
            
            request = URLRequest(url: urlFromComponents)
            
            var bodyData: Data
            
            do {
                bodyData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            } catch {
                throw error
            }
            
            request.httpBody = bodyData
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        if authorization.type == .tokenizationKey {
            headers["Client-Key"] = authorization.originalValue
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        
        return request
    }

    func handleRequestCompletion(
        data: Data? = nil,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) throws -> (BTJSON, HTTPURLResponse) {
        if let error {
            throw error
        }
        
        guard let response, let httpResponse = createHTTPResponse(response: response) else {
            throw BTHTTPError.httpResponseInvalid
        }
        
        guard let data else {
            throw BTHTTPError.dataNotFound
        }
        
        if httpResponse.statusCode >= 400 {
            let (_, error) = try handleHTTPResponseError(response: httpResponse, data: data)
            throw error
        }
        
        let json: BTJSON = data.isEmpty ? BTJSON() : BTJSON(data: data)
        if json.isError {
            try handleJSONResponseError(json: json, response: response)
        }
        
        return (json, httpResponse)
    }

    func createHTTPResponse(response: URLResponse) -> HTTPURLResponse? {
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse
        } else if let url = response.url, url.scheme == "data" {
            return HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        }
        return nil
    }

    func handleHTTPResponseError(response: HTTPURLResponse, data: Data) throws -> (BTJSON, Error) {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String: Any] = [BTCoreConstants.urlResponseKey: response]
        
        errorUserInfo[NSLocalizedFailureReasonErrorKey] = [HTTPURLResponse.localizedString(forStatusCode: response.statusCode)]
        
        var json = BTJSON()
        if responseContentType == "application/json" {
            json = data.isEmpty ? BTJSON() : BTJSON(data: data)
            if !json.isError {
                errorUserInfo[BTCoreConstants.jsonResponseBodyKey] = json
                let errorResponseMessage: String? = json["error"]["developer_message"].asString() ?? json["error"]["message"].asString()
                if errorResponseMessage != nil {
                    errorUserInfo[NSLocalizedDescriptionKey] = errorResponseMessage
                }
            }
        }
        
        var error = BTHTTPError.clientError(errorUserInfo)
        
        if response.statusCode == 429 {
            errorUserInfo[NSLocalizedDescriptionKey] = "You are being rate-limited."
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again in a few minutes."
            error = BTHTTPError.rateLimitError(errorUserInfo)
        } else if response.statusCode <= 500 {
            error = BTHTTPError.clientError(errorUserInfo)
        } else if response.statusCode >= 500 {
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again later."
            error = BTHTTPError.serverError(errorUserInfo)
        }
        
        return (json, error)
    }

    func handleJSONResponseError(
        json: BTJSON,
        response: URLResponse
    ) throws {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String: Any] = [BTCoreConstants.urlResponseKey: response]

        if let contentType = responseContentType, contentType != "application/json" {
            // Return error for unsupported response type
            let message = "BTHTTP only supports application/json responses, received Content-Type: \(contentType)"
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = message
            throw BTHTTPError.responseContentTypeNotAcceptable(errorUserInfo)
        } else if let error = json.asError() {
            throw error
        }
    }

    // MARK: - Helper functions

    func pinnedCertificateData() -> [SecCertificate] {
        var certificates: [SecCertificate] = []

        for certificateData in pinnedCertificates {
            guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else { return [] }
            certificates.append(certificate)
        }

        return certificates
    }

    // MARK: - URLSessionTaskDelegate conformance

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let domain: String = challenge.protectionSpace.host
            // swiftlint:disable force_unwrapping
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
            // swiftlint:enable force_unwrapping

            let policies: [SecPolicy] = [SecPolicyCreateSSL(true, domain as CFString)]
            SecTrustSetPolicies(serverTrust, policies as CFArray)
            SecTrustSetAnchorCertificates(serverTrust, pinnedCertificateData() as CFArray)

            var error: CFError?
            let trusted: Bool = SecTrustEvaluateWithError(serverTrust, &error)

            if trusted && error == nil {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metrics.transactionMetrics.forEach { transaction in
            if let startDate = transaction.fetchStartDate,
                let endDate = transaction.responseEndDate,
                var path = transaction.request.url?.path {
                if path.contains("graphql"),
                    let data = task.originalRequest?.httpBody,
                    let mutationName = getGraphQLMutationName(data) {
                        path = mutationName
                }
                
                networkTimingDelegate?.fetchAPITiming(
                    path: path,
                    connectionStartTime: transaction.connectStartDate?.utcTimestampMilliseconds,
                    requestStartTime: transaction.requestStartDate?.utcTimestampMilliseconds,
                    startTime: startDate.utcTimestampMilliseconds,
                    endTime: endDate.utcTimestampMilliseconds
                )
            }
        }
    }
    
    private func getGraphQLMutationName(_ data: Data) -> String? {
        let json = try? JSONSerialization.jsonObject(with: data)
        let body = BTJSON(value: json)
        
        guard let query = body["query"].asString() else {
            return nil
        }

        let queryDiscardHolder = query.replacingOccurrences(of: #"^[^\(]*"#, with: "", options: .regularExpression)
        let finalQuery = query.replacingOccurrences(of: queryDiscardHolder, with: "")
        return finalQuery
    }
}
