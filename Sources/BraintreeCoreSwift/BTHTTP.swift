import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
// TODO: once BTAPIHTTP + BTGraphQLHTTP are converted this can be internal + more Swift-y
// TODO: When BTAPIHTTP + BTGraphQL are converted we should update the dictionaries to [String: Any]
@objcMembers public class BTHTTPSwift: NSObject, NSCopying, URLSessionDelegate {

    /// An optional array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    public var pinnedCertificates: [NSData]? = []

    /// Session exposed for testing
    public var session: URLSession?

    /// internal date cache validator for testing
    let cacheDateValidator: BTCacheDateValidator

    let baseURL: URL
    var authorizationFingerprint: String = ""
    var tokenizationKey: String = ""
    private var _dispatchQueue: DispatchQueue?
    public var dispatchQueue: DispatchQueue {
        get {
            return _dispatchQueue ?? DispatchQueue.main
        }
        set {
            _dispatchQueue = newValue
        }
    }
    
    // MARK: Initializers

    /// Initialize `BTHTTP` with the URL for the Braintree API
    /// - Parameter url: The base URL for the Braintree Client API
    @objc(initWithBaseURL:)
    public init(url: URL) {
        self.baseURL = url
        self.cacheDateValidator = BTCacheDateValidator()
    }

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a client token
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - authorizationFingerprint: The authorization fingerprint HMAC from a client token
    @objc(initWithBaseURL:authorizationFingerprint:)
    public convenience init(url: URL, authorizationFingerprint: String) {
        self.init(url: url)

        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders()

        let delegateQueue: OperationQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        delegateQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount

        self.authorizationFingerprint = authorizationFingerprint
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        self.pinnedCertificates = BTAPIPinnedCertificates.trustedCertificates()
    }

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a tokenizationKey
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - tokenizationKey: The authorization fingerprint HMAC from a client token
    @objc(initWithBaseURL:tokenizationKey:)
    public convenience init(url: URL, tokenizationKey: String) {
        self.init(url: url)

        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders()

        let delegateQueue: OperationQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        delegateQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount

        self.tokenizationKey = tokenizationKey
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        self.pinnedCertificates = BTAPIPinnedCertificates.trustedCertificates()
    }

    /// Initialize `BTHTTP` with the authorization fingerprint from a client token
    /// - Parameter clientToken: The client token
    @objc(initWithClientToken:)
    public convenience init(clientToken: BTClientToken) {
        // TODO: force unwrapping fix
        self.init(url: ((clientToken.json?["clientApiUrl"].asURL() ?? URL(string: ""))!), authorizationFingerprint: clientToken.authorizationFingerprint ?? "")
    }

    // MARK: - HTTP Methods

    @objc(GET:completion:)
    public func get(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        get(path, parameters: nil, completion: completion)
    }

    @objc(GET:parameters:shouldCache:completion:)
    public func get(_ path: String, parameters: NSDictionary? = nil, shouldCache: Bool, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        if shouldCache {
            httpRequestWithCaching(method: "GET", path: path, parameters: parameters, completion: completion)
        } else {
            httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
        }
    }

    @objc(GET:parameters:completion:)
    public func get(_ path: String, parameters: NSDictionary? = nil, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
    }

    @objc(POST:completion:)
    public func post(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        post(path, parameters: nil, completion: completion)
    }

    @objc(POST:parameters:completion:)
    public func post(_ path: String, parameters: NSDictionary? = nil, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        httpRequest(method: "POST", path: path, parameters: parameters, completion: completion)
    }

    @objc(PUT:completion:)
    public func put(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        put(path, parameters: nil, completion: completion)
    }

    @objc(PUT:parameters:completion:)
    public func put(_ path: String, parameters: NSDictionary? = nil, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        httpRequest(method: "PUT", path: path, parameters: parameters, completion: completion)
    }

    @objc(DELETE:completion:)
    public func delete(_ path: String, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        delete(path, parameters: nil, completion: completion)
    }

    @objc(DELETE:parameters:completion:)
    public func delete(_ path: String, parameters: NSDictionary? = nil, completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void) {
        httpRequest(method: "DELETE", path: path, parameters: parameters, completion: completion)
    }


    // MARK: - HTTP Method Helpers

    func httpRequestWithCaching(
        method: String?,
        path: String?,
        parameters: NSDictionary? = [:],
        completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void
    ) {
        createRequest(method: method, path: path, parameters: parameters) { request, error in
            guard let request = request else {
                self.handleRequestCompletion(data: nil, request: nil, shouldCache: false, response: nil, error: error, completion: completion)
                return
            }

            var cachedResponse: CachedURLResponse? = URLCache.shared.cachedResponse(for: request) ?? nil

            // TODO: don't force unwrap
            if self.cacheDateValidator.isCacheInvalid(cachedResponse ?? nil) {
                URLCache.shared.removeAllCachedResponses()
                cachedResponse = nil
            }

            // The increase in speed of API calls with cached configuration caused an increase in "network connection lost" errors.
            // Adding this delay allows us to throttle the network requests slightly to reduce load on the servers and decrease connection lost errors.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if cachedResponse != nil {
                    self.handleRequestCompletion(data: cachedResponse?.data, request: nil, shouldCache: false, response: cachedResponse?.response, error: nil, completion: completion)
                } else {
                    let task: URLSessionTask? = self.session?.dataTask(with: request) { data, response, error in
                        self.handleRequestCompletion(data: data, request: request, shouldCache: true, response: response, error: error, completion: completion)
                    }
                    task?.resume()
                }
            }
        }
    }

    func httpRequest(
        method: String?,
        path: String?,
        parameters: NSDictionary? = [:],
        completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void
    ) {
        createRequest(method: method, path: path, parameters: parameters) { request, error in
            guard let request = request else {
                self.handleRequestCompletion(data: nil, request: nil, shouldCache: false, response: nil, error: error, completion: completion)
                return
            }

            let task: URLSessionTask? = self.session?.dataTask(with: request) { data, response, error in
                self.handleRequestCompletion(data: data, request: request, shouldCache: false, response: response, error: error, completion: completion)
            }
            task?.resume()
        }
    }

    func createRequest(
        method: String?,
        path: String?,
        parameters: NSDictionary? = [:],
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        let hasHTTPPrefix: Bool = path?.hasPrefix("http") ?? false
        let baseURLString: String = baseURL.absoluteString
        var errorUserInfo: [String: Any] = [:]

        if hasHTTPPrefix && (!baseURLString.isEmpty || baseURLString == "") {
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            let error = constructError(code: .missingBaseURL, userInfo: errorUserInfo)

            completion(nil, error)
            return
        }
        
        let fullPathURL: URL?
        let isNotDataURL: Bool = baseURL.scheme != "data"
        if isNotDataURL, let path = path {
            fullPathURL = hasHTTPPrefix ? URL(string: path) : baseURL.appendingPathComponent(path)
        } else {
            fullPathURL = baseURL
        }

        let mutableParameters: NSMutableDictionary = NSMutableDictionary(dictionary: parameters ?? [:])

        if authorizationFingerprint != "" {
            mutableParameters["authorization_fingerprint"] = authorizationFingerprint
        }

        guard let fullPathURL = fullPathURL else {
            /// baseURL can be non-nil (e.g. an empty string) and still return nil for -URLByAppendingPathComponent:
            /// causing a crash when NSURLComponents.componentsWithString is called with nil.
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "fullPathURL was nil"

            let error = constructError(code: .missingBaseURL, userInfo: errorUserInfo)

            completion(nil, error)
            return
        }

        buildHTTPRequest(
            method: method,
            url: fullPathURL,
            parameters: mutableParameters,
            isNotDataURL: isNotDataURL
        ) { request, error in
            completion(request, error)
        }
    }

    func buildHTTPRequest(
        method: String?,
        url: URL,
        parameters: NSMutableDictionary? = [:],
        isNotDataURL: Bool,
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        guard var components: URLComponents = URLComponents(string: url.absoluteString),
              let url = components.url else {
            let error = constructError(
                code: .urlStringInvalid,
                userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
            )

            completion(nil, error)
            return
        }

        var headers: [String: String] = defaultHeaders()
        var request: URLRequest

        if method == "GET" || method == "DELETE" {
            if isNotDataURL {
                components.percentEncodedQuery = BTURLUtils.queryString(from: parameters ?? [:])
            }

            request = URLRequest(url: url)
        } else {
            request = URLRequest(url: url)

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

        if tokenizationKey != "" {
            headers["Client-Key"] = tokenizationKey
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
        completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void
    ) {
        /// Handle errors for which the response is irrelevant e.g. SSL, unavailable network, etc.
        guard error == nil else {
            completion(nil, nil, error)
            return
        }

        guard let response = response,
              let httpResponse = createHTTPResponse(response: response) else {
            let error = constructError(
                code: .httpResponseInvalid,
                userInfo: [NSLocalizedDescriptionKey : "Unable to create HTTPURLResponse from response data."]
            )

            completion(nil, nil, error)
            return
        }

        guard let data = data else {
            let error = constructError(code: .dataNotFound, userInfo: [NSLocalizedDescriptionKey: "Data unexpectedly nil."])

            completion(nil, nil, error)
            return
        }

        if httpResponse.statusCode >= 400 {
            handleHTTPResponseError(response: httpResponse, data: data) { json, error in
                completion(json, httpResponse, error)
            }
            return
        }

        // Empty response is valid
        let json: BTJSON = data.isEmpty ? BTJSON() : BTJSON(data: data)
        if json.isError {
            handleJSONResponseError(json: json, response: httpResponse) { error in
                completion(nil, nil, error)
            }
            return
        }

        // We should only cache the response if we do not have an error and status code is 2xx
        let successStatusCode: Bool = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300

        if request != nil && shouldCache && successStatusCode, let request = request {
            let cachedURLResponse: CachedURLResponse = CachedURLResponse(response: response, data: data)

            URLCache.shared.storeCachedResponse(cachedURLResponse, for: request)
        }

        completion(json, httpResponse, nil)
    }
    
    func callCompletionBlock(_ completion: @escaping (BTJSON?, HTTPURLResponse?, Error?) -> Void, body: BTJSON?, response: HTTPURLResponse, error: NSError?) {
        self.dispatchQueue.async {
            completion(body, response, error)
        }
    }

    func createHTTPResponse(response: URLResponse) -> HTTPURLResponse? {
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse
        } else if let url = response.url, url.scheme == "data" {
            return HTTPURLResponse(url: url,
                                   statusCode: 200,
                                   httpVersion: nil,
                                   headerFields: nil)
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

        let error = constructError(code: errorCode, userInfo: errorUserInfo)

        completion(json, error)
    }

    func handleJSONResponseError(
        json: BTJSON,
        response: HTTPURLResponse,
        completion: @escaping (Error?) -> Void
    ) {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String : Any] = [BTHTTPError.urlResponseKey: response]

        if let contentType = responseContentType, contentType != "application/json" {
            // Return error for unsupported response type
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "BTHTTP only supports application/json responses, received Content-Type: \(contentType)"
            let returnedError: NSError = constructError(code: .responseContentTypeNotAcceptable, userInfo: errorUserInfo)

            completion(returnedError)
        } else {
            completion(json.asError())
        }
    }

    func constructError(code: BTHTTPErrorCode, userInfo: [String: Any]) -> NSError {
        NSError(domain: BTHTTPError.domain, code: code.rawValue, userInfo: userInfo)
    }

    // MARK: - Default Headers

    func defaultHeaders() -> [String: String] {
        [
            "User-Agent": userAgentString(),
            "Accept": "application/json",
            "Accept-Language": acceptLanguageString()
        ]
    }

    func userAgentString() -> String {
        "Braintree/iOS/\(BraintreeCoreConstants.braintreeVersion)"
    }

    func acceptLanguageString() -> String {
        "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "US")"
    }

    // MARK: - Helper functions

    func pinnedCertificateData() -> [NSData]? {
        var certificates: [NSData] = []

        for certificateData in pinnedCertificates ?? [] {
            guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else { return nil }
            let certificateData = SecCertificateCopyData(certificate)
            certificates.append(certificateData)
        }

        return certificates
    }

    // MARK: - isEqual override

    func isEqualToHTTP(http: BTHTTPSwift) -> Bool {
        baseURL == http.baseURL && authorizationFingerprint == http.authorizationFingerprint
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard object is BTHTTPSwift,
              let otherObject = object as? BTHTTPSwift else {
            return false
        }

        return isEqualToHTTP(http: otherObject)
    }

    // MARK: - NSCopying conformance

    public func copy(with zone: NSZone? = nil) -> Any {
        let copiedHTTP: BTHTTPSwift

        if authorizationFingerprint != "" {
            copiedHTTP = BTHTTPSwift(url: baseURL, authorizationFingerprint: authorizationFingerprint)
        } else {
            copiedHTTP = BTHTTPSwift(url: baseURL, tokenizationKey: tokenizationKey)
        }

        copiedHTTP.pinnedCertificates = pinnedCertificates
        return copiedHTTP
    }
}
