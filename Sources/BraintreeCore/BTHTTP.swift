import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
class BTHTTP: NSObject, URLSessionTaskDelegate {

    typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    enum ClientAuthorization: Equatable {
        case authorizationFingerprint(String), tokenizationKey(String)
    }

    // MARK: - Internal Properties

    /// An array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    let pinnedCertificates: [NSData] = BTAPIPinnedCertificates.trustedCertificates()
    let baseURL: URL

    /// DispatchQueue on which asynchronous code will be executed. Defaults to `DispatchQueue.main`.
    var dispatchQueue: DispatchQueue = DispatchQueue.main
    var clientAuthorization: ClientAuthorization?

    weak var networkTimingDelegate: BTHTTPNetworkTiming?

    /// Session exposed for testing
    lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders
        
        let delegateQueue: OperationQueue = OperationQueue()
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

    func get(_ path: String, parameters: Encodable? = nil, completion: @escaping RequestCompletion) {
        do {
            let dict = try parameters?.toDictionary()
            
            httpRequest(method: "GET", path: path, parameters: dict, completion: completion)
        } catch let error {
            completion(nil, nil, error)
        }
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

    // MARK: - HTTP Method Helpers

    func httpRequest(
        method: String,
        path: String,
        parameters: [String: Any]? = [:],
        completion: RequestCompletion?
    ) {
        do {
            let request = try createRequest(method: method, path: path, parameters: parameters)
            
            self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self else {
                    completion?(nil, nil, BTHTTPError.deallocated("BTHTTP"))
                    return
                }

                handleRequestCompletion(data: data, request: request, response: response, error: error, completion: completion)
            }.resume()
        } catch {
            self.handleRequestCompletion(data: nil, request: nil, response: nil, error: error, completion: completion)
            return
        }
    }

    func createRequest(
        method: String,
        path: String,
        parameters: [String: Any]? = [:]
    ) throws -> URLRequest {
        let hasHTTPPrefix: Bool = path.hasPrefix("http")
        let baseURLString: String = baseURL.absoluteString
        var errorUserInfo: [String: Any] = [:]

        if hasHTTPPrefix && (baseURLString.isEmpty || baseURLString == "") {
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            throw BTHTTPError.missingBaseURL(errorUserInfo)
        }
        
        let fullPathURL = hasHTTPPrefix ? URL(string: path) : baseURL.appendingPathComponent(path)

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

            throw BTHTTPError.missingBaseURL(errorUserInfo)
        }

        return try buildHTTPRequest(
            method: method,
            url: fullPathURL,
            parameters: mutableParameters
        )
    }

    func buildHTTPRequest(
        method: String,
        url: URL,
        parameters: NSMutableDictionary? = [:]
    ) throws -> URLRequest {
        guard var components: URLComponents = URLComponents(string: url.absoluteString) else {
            throw BTHTTPError.urlStringInvalid
        }

        var headers: [String: String] = defaultHeaders
        var request: URLRequest

        if method == "GET" || method == "DELETE" {
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
        
        if case .tokenizationKey(let key) = clientAuthorization {
            headers["Client-Key"] = key
        }

        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        return request
    }

    func handleRequestCompletion(
        data: Data?,
        request: URLRequest?,
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

    // MARK: - URLSessionTaskDelegate conformance

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

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metrics.transactionMetrics.forEach { transaction in
            if let startDate = transaction.fetchStartDate,
               let endDate = transaction.responseEndDate,
               let path = transaction.request.url?.path {
                networkTimingDelegate?.fetchAPITiming(
                    path: path,
                    startTime: startDate.utcTimestampMilliseconds,
                    endTime: endDate.utcTimestampMilliseconds
                )
            }
        }
    }
}
