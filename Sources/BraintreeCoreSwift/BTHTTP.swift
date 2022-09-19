import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
// TODO: once BTAPIHTTP + BTGraphQLHTTP are converted this can be internal + more Swift-y
// TODO: When BTAPIHTTP + BTGraphQL are converted we should update the dictionaries to [String: Any]
@objcMembers public class BTHTTP: NSObject, NSCopying, URLSessionDelegate {
// TODO: - Mark interval vs private properties accordingly
    public typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    enum ClientAuthorization: Equatable {
        case authorizationFingerprint(String), tokenizationKey(String)
    }
    
    // MARK: - Public Properties
    
    /// An array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    public let pinnedCertificates: [NSData] = BTAPIPinnedCertificates.trustedCertificates()

    // TODO: Make internal with Swift test?
    /// Session exposed for testing
    public lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders()
        
        let delegateQueue: OperationQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        delegateQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }()

    // TODO: Make internal with Swift test?
    /// DispatchQueue on which asynchronous code will be executed. Defaults to `DispatchQueue.main`.
    public var dispatchQueue: DispatchQueue = DispatchQueue.main

    // TODO: Make internal after BTAnalyticsService is converted to Swift
    public let baseURL: URL

    // MARK: - Internal Properties
    
    let cacheDateValidator: BTCacheDateValidator = BTCacheDateValidator()
    var clientAuthorization: ClientAuthorization?
    
    // MARK: - Internal Initializer
    
    init(url: URL) {
        self.baseURL = url
    }

    // MARK: - Public Initializers

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a client token
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - authorizationFingerprint: The authorization fingerprint HMAC from a client token
    @objc(initWithBaseURL:authorizationFingerprint:)
    public init(url: URL, authorizationFingerprint: String) {
        self.baseURL = url
        self.clientAuthorization = .authorizationFingerprint(authorizationFingerprint)
    }

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a tokenizationKey
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - tokenizationKey: The authorization fingerprint HMAC from a client token
    @objc(initWithBaseURL:tokenizationKey:)
    public init(url: URL, tokenizationKey: String) {
        self.baseURL = url
        self.clientAuthorization = .tokenizationKey(tokenizationKey)
    }

    /// Initialize `BTHTTP` with the authorization fingerprint from a client token
    /// - Parameter clientToken: The client token
    @objc(initWithClientToken:error:)
    public convenience init(clientToken: BTClientToken) throws {
        let url: URL

        if clientToken.json["clientApiUrl"].asURL() != nil, let clientApiURL = clientToken.json["clientApiUrl"].asURL() {
            url = clientApiURL
        } else if clientToken.json["configUrl"].asURL() != nil, let configURL = clientToken.json["configUrl"].asURL() {
            url = configURL
        } else {
            throw Self.constructError(
                code: .clientApiUrlInvalid,
                userInfo: [NSLocalizedDescriptionKey: "Client API URL is not a valid URL."]
            )
        }
        
        if clientToken.authorizationFingerprint.isEmpty {
            throw Self.constructError(
                code: .invalidAuthorizationFingerprint,
                userInfo: [NSLocalizedDescriptionKey: "BTClientToken contained a nil or empty authorizationFingerprint."]
            )
        }

        self.init(url: url, authorizationFingerprint: clientToken.authorizationFingerprint)
    }

    // MARK: - HTTP Methods

    @objc(GET:completion:)
    public func get(_ path: String, completion: @escaping RequestCompletion) {
        get(path, parameters: nil, completion: completion)
    }

    @objc(GET:parameters:shouldCache:completion:)
    public func get(_ path: String, parameters: NSDictionary? = nil, shouldCache: Bool, completion: RequestCompletion?) {
        if shouldCache {
            httpRequestWithCaching(method: "GET", path: path, parameters: parameters, completion: completion)
        } else {
            httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
        }
    }

    @objc(GET:parameters:completion:)
    public func get(_ path: String, parameters: NSDictionary? = nil, completion: RequestCompletion?) {
        httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
    }

    @objc(POST:completion:)
    public func post(_ path: String, completion: @escaping RequestCompletion) {
        post(path, parameters: nil, completion: completion)
    }

    @objc(POST:parameters:completion:)
    public func post(_ path: String, parameters: NSDictionary? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", path: path, parameters: parameters, completion: completion)
    }

    @objc(PUT:completion:)
    public func put(_ path: String, completion: @escaping RequestCompletion) {
        put(path, parameters: nil, completion: completion)
    }

    @objc(PUT:parameters:completion:)
    public func put(_ path: String, parameters: NSDictionary? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "PUT", path: path, parameters: parameters, completion: completion)
    }

    @objc(DELETE:completion:)
    public func delete(_ path: String, completion: @escaping RequestCompletion) {
        delete(path, parameters: nil, completion: completion)
    }

    @objc(DELETE:parameters:completion:)
    public func delete(_ path: String, parameters: NSDictionary? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "DELETE", path: path, parameters: parameters, completion: completion)
    }

    // MARK: - HTTP Method Helpers

    func httpRequestWithCaching(
        method: String,
        path: String,
        parameters: NSDictionary? = [:],
        completion: RequestCompletion?
    ) {
        createRequest(method: method, path: path, parameters: parameters) { request, error in
            guard let request = request else {
                self.handleRequestCompletion(data: nil, request: nil, shouldCache: false, response: nil, error: error, completion: completion)
                return
            }

            var cachedResponse: CachedURLResponse? = URLCache.shared.cachedResponse(for: request) ?? nil

            if self.cacheDateValidator.isCacheInvalid(cachedResponse ?? nil) {
                URLCache.shared.removeAllCachedResponses()
                cachedResponse = nil
            }

            // The increase in speed of API calls with cached configuration caused an increase in "network connection lost" errors.
            // Adding this delay allows us to throttle the network requests slightly to reduce load on the servers and decrease connection lost errors.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let cachedResponse = cachedResponse {
                    self.handleRequestCompletion(data: cachedResponse.data, request: nil, shouldCache: false, response: cachedResponse.response, error: nil, completion: completion)
                } else {
                    let task: URLSessionTask = self.session.dataTask(with: request) { [weak self] data, response, error in
                        guard let self = self else { return }
                        self.handleRequestCompletion(data: data, request: request, shouldCache: true, response: response, error: error, completion: completion)
                    }

                    task.resume()
                }
            }
        }
    }

    func httpRequest(
        method: String,
        path: String,
        parameters: NSDictionary? = [:],
        completion: RequestCompletion?
    ) {
        createRequest(method: method, path: path, parameters: parameters) { request, error in
            guard let request = request else {
                self.handleRequestCompletion(data: nil, request: nil, shouldCache: false, response: nil, error: error, completion: completion)
                return
            }

            let task: URLSessionTask = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                self.handleRequestCompletion(data: data, request: request, shouldCache: false, response: response, error: error, completion: completion)
            }

            task.resume()
        }
    }

    func createRequest(
        method: String,
        path: String,
        parameters: NSDictionary? = [:],
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        let hasHTTPPrefix: Bool = path.hasPrefix("http")
        let baseURLString: String = baseURL.absoluteString
        var errorUserInfo: [String: Any] = [:]

        if hasHTTPPrefix && (baseURLString.isEmpty || baseURLString == "") {
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            let error = Self.constructError(code: .missingBaseURL, userInfo: errorUserInfo)

            completion(nil, error)
            return
        }
        
        let fullPathURL: URL?
        let isDataURL: Bool = baseURL.scheme == "data"

        if !isDataURL {
            fullPathURL = hasHTTPPrefix ? URL(string: path) : baseURL.appendingPathComponent(path)
        } else {
            fullPathURL = baseURL
        }

        let mutableParameters: NSMutableDictionary = NSMutableDictionary(dictionary: parameters ?? [:])

        if case .authorizationFingerprint(let fingerprint) = clientAuthorization {
            mutableParameters["authorization_fingerprint"] = fingerprint
        }

        guard let fullPathURL = fullPathURL else {
            // baseURL can be non-nil (e.g. an empty string) and still return nil for appendingPathComponent(_:)
            // causing a crash when URLComponents(string:_) is called with nil.
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "fullPathURL was nil"

            let error = Self.constructError(code: .missingBaseURL, userInfo: errorUserInfo)

            completion(nil, error)
            return
        }

        buildHTTPRequest(
            method: method,
            url: fullPathURL,
            parameters: mutableParameters,
            isDataURL: isDataURL
        ) { request, error in
            completion(request, error)
        }
    }

    func buildHTTPRequest(
        method: String,
        url: URL,
        parameters: NSMutableDictionary? = [:],
        isDataURL: Bool,
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        guard var components: URLComponents = URLComponents(string: url.absoluteString) else {
            let error = Self.constructError(
                code: .urlStringInvalid,
                userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
            )

            completion(nil, error)
            return
        }

        var headers: [String: String] = defaultHeaders()
        var request: URLRequest

        if method == "GET" || method == "DELETE" {
            if !isDataURL {
                components.percentEncodedQuery = BTURLUtils.queryString(from: parameters ?? [:])
            }
            guard let urlFromComponents = components.url else {
                let error = Self.constructError(
                    code: .urlStringInvalid,
                    userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
                )
                completion(nil, error)
                return
            }

            request = URLRequest(url: urlFromComponents)
        } else {
            guard let urlFromComponents = components.url else {
                let error = Self.constructError(
                    code: .urlStringInvalid,
                    userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
                )
                completion(nil, error)
                return
            }

            request = URLRequest(url: urlFromComponents)

            var bodyData: Data

            do {
                bodyData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            } catch {
                completion(nil, error)
                return
            }

            request.httpBody = bodyData
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        if case .tokenizationKey(let key) = clientAuthorization {
            headers["Client-Key"] = key
        }

        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        completion(request, nil)
    }

    public func handleRequestCompletion(
        data: Data?,
        request: URLRequest?,
        shouldCache: Bool,
        response: URLResponse?,
        error: Error?,
        completion: RequestCompletion?
    ) {
        guard let completion = completion else {
            return
        }

        guard error == nil else {
            callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            return
        }

        guard let response = response,
              let httpResponse = createHTTPResponse(response: response) else {
            let error = Self.constructError(
                code: .httpResponseInvalid,
                userInfo: [NSLocalizedDescriptionKey : "Unable to create HTTPURLResponse from response data."]
            )
            callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            return
        }

        guard let data = data else {
            let error = Self.constructError(code: .dataNotFound, userInfo: [NSLocalizedDescriptionKey: "Data unexpectedly nil."])
            callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            return
        }

        if httpResponse.statusCode >= 400 {
            handleHTTPResponseError(response: httpResponse, data: data) { [weak self] json, error in
                guard let self = self else { return }
                self.callCompletionAsync(with: completion, body: json, response: httpResponse, error: error)
            }
            return
        }

        // Empty response is valid
        let json: BTJSON = data.isEmpty ? BTJSON() : BTJSON(data: data)
        if json.isError {
            handleJSONResponseError(json: json, response: response) { [weak self] error in
                guard let self = self else { return }
                self.callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            }
            return
        }

        // We should only cache the response if we do not have an error and status code is 2xx
        let successStatusCode: Bool = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300

        if request != nil && shouldCache && successStatusCode, let request = request {
            let cachedURLResponse: CachedURLResponse = CachedURLResponse(response: response, data: data)

            URLCache.shared.storeCachedResponse(cachedURLResponse, for: request)
        }

        callCompletionAsync(with: completion, body: json, response: httpResponse, error: nil)
    }
    
    func callCompletionAsync(with completion: @escaping RequestCompletion, body: BTJSON?, response: HTTPURLResponse?, error: Error?) {
        self.dispatchQueue.async {
            completion(body, response, error)
        }
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

    func handleHTTPResponseError(response: HTTPURLResponse, data: Data, completion: (BTJSON, Error) -> Void) {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String : Any] = [BTHTTPError.urlResponseKey: response]

        errorUserInfo[NSLocalizedFailureReasonErrorKey] = [HTTPURLResponse.localizedString(forStatusCode: response.statusCode)]

        var json: BTJSON = BTJSON()
        if responseContentType == "application/json" {
            json = data.isEmpty ? BTJSON() : BTJSON(data: data)

            if !json.isError {
                errorUserInfo[BTHTTPError.jsonResponseBodyKey] = json
                let errorResponseMessage: String? = json["error"]["developer_message"].asString() ?? json["error"]["message"].asString()

                if errorResponseMessage != nil {
                    errorUserInfo[NSLocalizedDescriptionKey] = errorResponseMessage
                }
            }
        }

        var errorCode: BTHTTPErrorCode = response.statusCode >= 500 ? BTHTTPErrorCode.serverError : BTHTTPErrorCode.clientError

        if response.statusCode == 429 {
            errorCode = BTHTTPErrorCode.rateLimitError
            errorUserInfo[NSLocalizedDescriptionKey] = "You are being rate-limited."
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again in a few minutes."
        } else if response.statusCode >= 500 {
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again later."
        }

        let error = Self.constructError(code: errorCode, userInfo: errorUserInfo)

        completion(json, error)
    }

    func handleJSONResponseError(
        json: BTJSON,
        response: URLResponse,
        completion: @escaping (Error?) -> Void
    ) {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String : Any] = [BTHTTPError.urlResponseKey: response]

        if let contentType = responseContentType, contentType != "application/json" {
            // Return error for unsupported response type
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "BTHTTP only supports application/json responses, received Content-Type: \(contentType)"
            let returnedError: NSError = Self.constructError(code: .responseContentTypeNotAcceptable, userInfo: errorUserInfo)

            completion(returnedError)
        } else {
            completion(json.asError())
        }
    }

    static func constructError(code: BTHTTPErrorCode, userInfo: [String: Any]) -> NSError {
        NSError(domain: BTHTTPError.domain, code: code.rawValue, userInfo: userInfo)
    }

    // MARK: - Default Headers

    func defaultHeaders() -> [String: String] {
        [
            "User-Agent": userAgentString(),
            "Accept": acceptString(),
            "Accept-Language": acceptLanguageString()
        ]
    }

    func userAgentString() -> String {
        "Braintree/iOS/\(BTCoreConstants.braintreeSDKVersion)"
    }

    func acceptString() -> String {
        "application/json"
    }

    func acceptLanguageString() -> String {
        "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "US")"
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

    // MARK: - isEqual override
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard object is BTHTTP,
              let otherObject = object as? BTHTTP else {
            return false
        }

        return baseURL == otherObject.baseURL && clientAuthorization == otherObject.clientAuthorization
    }

    // MARK: - NSCopying conformance

    public func copy(with zone: NSZone? = nil) -> Any {
        switch clientAuthorization {
        case .authorizationFingerprint(let fingerprint):
            return BTHTTP(url: baseURL, authorizationFingerprint: fingerprint)
        case .tokenizationKey(let key):
            return BTHTTP(url: baseURL, tokenizationKey: key)
        default:
            return BTHTTP(url: baseURL)
        }
    }

    // MARK: - URLSessionDelegate conformance

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let domain: String = challenge.protectionSpace.host
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!

            let policies: [SecPolicy] = [SecPolicyCreateSSL(true, domain as CFString)]
            SecTrustSetPolicies(serverTrust, policies as CFArray)

            let pinnedCertificates = pinnedCertificateData()
            SecTrustSetAnchorCertificates(serverTrust, pinnedCertificates as CFArray)

            var error: CFError?
            let trusted: Bool = SecTrustEvaluateWithError(serverTrust, &error)

            if trusted && error == nil {
                let credential: URLCredential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
