import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
class BTHTTP: NSObject, NSCopying, URLSessionDelegate {

    typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    enum ClientAuthorization: Equatable {
        case authorizationFingerprint(String), tokenizationKey(String)
    }

    // MARK: - Internal Properties

    /// An array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    let pinnedCertificates: [NSData] = BTAPIPinnedCertificates.trustedCertificates()

    /// DispatchQueue on which asynchronous code will be executed. Defaults to `DispatchQueue.main`.
    var dispatchQueue: DispatchQueue = DispatchQueue.main
    let baseURL: URL
    let cacheDateValidator: BTCacheDateValidator = BTCacheDateValidator()
    var clientAuthorization: ClientAuthorization?

    /// Session exposed for testing
    lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders
        
        let delegateQueue: OperationQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        delegateQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
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
    
    init(url: URL) {
        self.baseURL = url
    }

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a client token
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - authorizationFingerprint: The authorization fingerprint HMAC from a client token
    init(url: URL, authorizationFingerprint: String) {
        self.baseURL = url
        self.clientAuthorization = .authorizationFingerprint(authorizationFingerprint)
    }

    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a tokenizationKey
    /// - Parameters:
    ///   - url: The base URL for the Braintree Client API
    ///   - tokenizationKey: The authorization fingerprint HMAC from a client token
    init(url: URL, tokenizationKey: String) {
        self.baseURL = url
        self.clientAuthorization = .tokenizationKey(tokenizationKey)
    }

    /// Initialize `BTHTTP` with the authorization fingerprint from a client token
    /// - Parameter clientToken: The client token
    convenience init(clientToken: BTClientToken) throws {
        let url: URL

        if let clientApiURL = clientToken.json["clientApiUrl"].asURL() {
            url = clientApiURL
        } else if let configURL = clientToken.json["configUrl"].asURL() {
            url = configURL
        } else {
            throw BTHTTPError.clientApiURLInvalid
        }
        
        if clientToken.authorizationFingerprint.isEmpty {
            throw BTHTTPError.invalidAuthorizationFingerprint
        }

        self.init(url: url, authorizationFingerprint: clientToken.authorizationFingerprint)
    }

    // MARK: - HTTP Methods

    func get(_ path: String, completion: @escaping RequestCompletion) {
        get(path, parameters: nil, completion: completion)
    }

    func get(_ path: String, parameters: [String: Any]? = nil, shouldCache: Bool, completion: RequestCompletion?) {
        if shouldCache {
            httpRequestWithCaching(method: "GET", path: path, parameters: parameters, completion: completion)
        } else {
            httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
        }
    }

    func get(_ path: String, parameters: [String: Any]? = nil, completion: RequestCompletion?) {
        httpRequest(method: "GET", path: path, parameters: parameters, completion: completion)
    }

    func post(_ path: String, completion: @escaping RequestCompletion) {
        post(path, parameters: nil, completion: completion)
    }

    // TODO: - Remove when all POST bodies use Codable, instead of BTJSON/raw dictionaries
    func post(_ path: String, parameters: [String: Any]? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", path: path, parameters: parameters, completion: completion)
    }
    
    func post(_ path: String, parameters: Encodable, completion: @escaping RequestCompletion) {
        do {
            let dict = try parameters.toDictionary()
            post(path, parameters: dict, completion: completion)
        } catch let error {
            completion(nil, nil, error)
        }
    }

    func put(_ path: String, completion: @escaping RequestCompletion) {
        put(path, parameters: nil, completion: completion)
    }

    func put(_ path: String, parameters: [String: Any]? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "PUT", path: path, parameters: parameters, completion: completion)
    }

    func delete(_ path: String, completion: @escaping RequestCompletion) {
        delete(path, parameters: nil, completion: completion)
    }

    func delete(_ path: String, parameters: [String: Any]? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "DELETE", path: path, parameters: parameters, completion: completion)
    }

    // MARK: - HTTP Method Helpers

    func httpRequestWithCaching(
        method: String,
        path: String,
        parameters: [String: Any]? = [:],
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
                    self.session.dataTask(with: request) { [weak self] data, response, error in
                        guard let self else {
                            completion?(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                            return
                        }

                        handleRequestCompletion(data: data, request: request, shouldCache: true, response: response, error: error, completion: completion)
                    }.resume()
                }
            }
        }
    }

    func httpRequest(
        method: String,
        path: String,
        parameters: [String: Any]? = [:],
        completion: RequestCompletion?
    ) {
        createRequest(method: method, path: path, parameters: parameters) { request, error in
            guard let request = request else {
                self.handleRequestCompletion(data: nil, request: nil, shouldCache: false, response: nil, error: error, completion: completion)
                return
            }

            self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self else {
                    completion?(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                    return
                }

                handleRequestCompletion(data: data, request: request, shouldCache: false, response: response, error: error, completion: completion)
            }.resume()
        }
    }

    func createRequest(
        method: String,
        path: String,
        parameters: [String: Any]? = [:],
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        let hasHTTPPrefix: Bool = path.hasPrefix("http")
        let baseURLString: String = baseURL.absoluteString
        var errorUserInfo: [String: Any] = [:]

        if hasHTTPPrefix && (baseURLString.isEmpty || baseURLString == "") {
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            completion(nil, BTHTTPError.missingBaseURL(errorUserInfo))
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

        // TODO: - Investigate for parity on JS and Android
        // JIRA - DTBTSDK-2682
        if case .authorizationFingerprint(let fingerprint) = clientAuthorization,
           !baseURL.isPayPalURL {
            mutableParameters["authorization_fingerprint"] = fingerprint
        }

        guard let fullPathURL = fullPathURL else {
            // baseURL can be non-nil (e.g. an empty string) and still return nil for appendingPathComponent(_:)
            // causing a crash when URLComponents(string:_) is called with nil.
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "fullPathURL was nil"

            completion(nil, BTHTTPError.missingBaseURL(errorUserInfo))
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
            completion(nil, BTHTTPError.urlStringInvalid)
            return
        }

        var headers: [String: String] = defaultHeaders
        var request: URLRequest

        if method == "GET" || method == "DELETE" {
            if !isDataURL {
                components.percentEncodedQuery = BTURLUtils.queryString(from: parameters ?? [:])
            }
            guard let urlFromComponents = components.url else {
                completion(nil, BTHTTPError.urlStringInvalid)
                return
            }

            request = URLRequest(url: urlFromComponents)
        } else {
            guard let urlFromComponents = components.url else {
                completion(nil, BTHTTPError.urlStringInvalid)
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

    func handleRequestCompletion(
        data: Data?,
        request: URLRequest?,
        shouldCache: Bool,
        response: URLResponse?,
        error: Error?,
        completion: RequestCompletion?
    ) {
        guard let completion = completion else { return }

        guard error == nil else {
            callCompletionAsync(with: completion, body: nil, response: nil, error: error)
            return
        }

        guard let response = response,
              let httpResponse = createHTTPResponse(response: response) else {
            callCompletionAsync(with: completion, body: nil, response: nil, error: BTHTTPError.httpResponseInvalid)
            return
        }

        guard let data = data else {
            callCompletionAsync(with: completion, body: nil, response: nil, error: BTHTTPError.dataNotFound)
            return
        }

        if httpResponse.statusCode >= 400 {
            handleHTTPResponseError(response: httpResponse, data: data) { [weak self] json, error in
                guard let self else {
                    completion(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                    return
                }

                callCompletionAsync(with: completion, body: json, response: httpResponse, error: error)
            }
            return
        }

        // Empty response is valid
        let json: BTJSON = data.isEmpty ? BTJSON() : BTJSON(data: data)
        if json.isError {
            handleJSONResponseError(json: json, response: response) { [weak self] error in
                guard let self else {
                    completion(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                    return
                }

                callCompletionAsync(with: completion, body: nil, response: nil, error: error)
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
        var errorUserInfo: [String: Any] = [BTCoreConstants.urlResponseKey: response]

        errorUserInfo[NSLocalizedFailureReasonErrorKey] = [HTTPURLResponse.localizedString(forStatusCode: response.statusCode)]

        var json: BTJSON = BTJSON()
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

        var error: BTHTTPError = BTHTTPError.clientError(errorUserInfo)

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

        completion(json, error)
    }

    func handleJSONResponseError(
        json: BTJSON,
        response: URLResponse,
        completion: @escaping (Error?) -> Void
    ) {
        let responseContentType: String? = response.mimeType
        var errorUserInfo: [String : Any] = [BTCoreConstants.urlResponseKey: response]

        if let contentType = responseContentType, contentType != "application/json" {
            // Return error for unsupported response type
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "BTHTTP only supports application/json responses, received Content-Type: \(contentType)"
            completion(BTHTTPError.responseContentTypeNotAcceptable(errorUserInfo))
        } else {
            completion(json.asError())
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

    // MARK: - isEqual override
    
    override func isEqual(_ object: Any?) -> Bool {
        guard object is BTHTTP,
              let otherObject = object as? BTHTTP else {
            return false
        }

        return baseURL == otherObject.baseURL && clientAuthorization == otherObject.clientAuthorization
    }

    // MARK: - NSCopying conformance

    func copy(with zone: NSZone? = nil) -> Any {
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

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let domain: String = challenge.protectionSpace.host
            let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!

            let policies: [SecPolicy] = [SecPolicyCreateSSL(true, domain as CFString)]
            SecTrustSetPolicies(serverTrust, policies as CFArray)
            SecTrustSetAnchorCertificates(serverTrust, pinnedCertificateData() as CFArray)

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
