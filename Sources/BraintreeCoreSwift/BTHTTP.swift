import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
// TODO: once BTAPIHTTP + BTGraphQLHTTP are converted this can be internal + more Swift-y
@objcMembers public class BTHTTPSwift: NSObject, NSCopying {

    /// An optional array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    let pinnedCertificates: [NSData]? = []

    /// internal date cache validator for testing
    let cacheDataValidator: BTCacheDateValidator

    let baseURL: URL
    let authorizationFingerprint: String = ""
    let tokenizationKey: String = ""

    /// Initialize `BTHTTP` with the URL for the Braintree API
    /// - Parameter url: The base URL for the Braintree Client API
    @objc(initWithBaseURL:)
    public init(url: URL) {
        self.baseURL = url
        self.cacheDataValidator = BTCacheDateValidator()
    }

//    /// Initialize `BTHTTP` with the URL from Braintree API and the authorization fingerprint from a client token
//    /// - Parameters:
//    ///   - baseURL: The base URL for the Braintree Client API
//    ///   - authorizationFingerprint: The authorization fingerprint HMAC from a client token
//    @objc(initWithBaseURL:authorizationFingerprint:)
//    public convenience init(url: URL, authorizationFingerprint: String) {
//        self.init(url: url)
//    }
//

    // MARK: - HTTP helpers

    func createRequest(
        method: String?,
        path: String?,
        parameters: NSMutableDictionary = [:],
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        var hasHTTPPrefix: Bool = false

        if path != nil, let path = path {
            hasHTTPPrefix = path.hasPrefix("http")
        }

        if hasHTTPPrefix && (!baseURL.absoluteString.isEmpty || baseURL.absoluteString == "") {
            var errorUserInfo: [String: Any] = [:]

            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            let error = NSError(domain: BTHTTPError.domain, code: BTHTTPErrorCode.missingBaseURL.rawValue, userInfo: errorUserInfo)
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

        if authorizationFingerprint != "" {
            parameters["authorization_fingerprint"] = authorizationFingerprint
        }

        guard let fullPathURL = fullPathURL else {
            /// baseURL can be non-nil (e.g. an empty string) and still return nil for -URLByAppendingPathComponent:
            /// causing a crash when NSURLComponents.componentsWithString is called with nil.
            var errorUserInfo: [String: Any] = [:]
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = "fullPathURL was nil"

            let error = NSError(
                domain: BTHTTPError.domain,
                code: BTHTTPErrorCode.missingBaseURL.rawValue,
                userInfo: errorUserInfo
            )

            completion(nil, error)
            return
        }

        buildHTTPRequest(
            method: method,
            url: fullPathURL,
            parameters: parameters,
            isNotDataURL: isNotDataURL
        ) { request, error in
            completion(request, error)
        }
    }

    func buildHTTPRequest(
        method: String?,
        url: URL,
        parameters: NSMutableDictionary,
        isNotDataURL: Bool,
        completion: @escaping (URLRequest?, Error?) -> Void
    ) {
        guard var components: URLComponents = URLComponents(string: url.absoluteString),
              let url = components.url else {
            let error = NSError(
                domain: BTHTTPError.domain,
                code: BTHTTPErrorCode.unknown.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
            )
            completion(nil, error)
            return
        }

        var headers: [String: String] = defaultHeaders()
        var request: URLRequest

        if method == "GET" || method == "DELETE" {
            if isNotDataURL {
                components.percentEncodedQuery = BTURLUtils.queryString(from: parameters)
            }

            request = URLRequest(url: url)
        } else {
            request = URLRequest(url: url)

            var bodyData: Data

            do {
                bodyData = try JSONSerialization.data(withJSONObject: parameters)
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

    func handleRequestCompletion(
        data: Data,
        request: URLRequest?,
        shouldCache: Bool,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (BTJSON?, URLResponse?, Error?) -> Void
    ) {
        /// Handle errors for which the response is irrelevant e.g. SSL, unavailable network, etc.
        guard error == nil else {
            completion(nil, nil, error)
            return
        }

        guard let response = response,
              let httpResponse = createHTTPResponse(response: response) else {
            let error = NSError(
                domain: BTHTTPError.domain,
                code: BTHTTPErrorCode.unknown.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Unable to create HTTPURLResponse from response data."]
            )
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

    func createHTTPResponse(response: URLResponse) -> HTTPURLResponse? {
        if let url = response.url, url.scheme == "data" {
            guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else { return nil }

            return response
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

        var errorCode: Int = response.statusCode >= 500 ? BTHTTPErrorCode.serverError.rawValue : BTHTTPErrorCode.clientError.rawValue

        if response.statusCode == 429 {
            errorCode = BTHTTPErrorCode.rateLimitError.rawValue
            errorUserInfo[NSLocalizedDescriptionKey] = "You are being rate-limited."
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again in a few minutes."
        } else if response.statusCode >= 500 {
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = "Please try again later."
        }

        let error = NSError(domain: BTHTTPError.domain, code: errorCode, userInfo: errorUserInfo)

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
            let returnedError: NSError = NSError(domain: BTHTTPError.domain, code: BTHTTPErrorCode.responseContentTypeNotAcceptable.rawValue, userInfo: errorUserInfo)

            completion(returnedError)
        } else {
            completion(json.asError())
        }
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
        // TODO: Implement this
        return ""
    }
}
