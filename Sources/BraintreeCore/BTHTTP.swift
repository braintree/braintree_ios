import Foundation
import Security

/// Performs HTTP methods on the Braintree Client API
class BTHTTP: NSObject, URLSessionTaskDelegate {

    typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Internal Properties

    /// An array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
    let pinnedCertificates: [NSData] = BTAPIPinnedCertificates.trustedCertificates()

    /// DispatchQueue on which asynchronous code will be executed. Defaults to `DispatchQueue.main`.
    var dispatchQueue: DispatchQueue = DispatchQueue.main
    
    /// A URL set to override the URLs derived from the ClientAuthorization or BTConfiguration response
    let customBaseURL: URL?
    
    let authorization: ClientAuthorization
    
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
        do {
            let dict = try parameters?.toDictionary()
            
            httpRequest(method: "GET", path: path, configuration: configuration, parameters: dict, completion: completion)
        } catch let error {
            completion(nil, nil, error)
        }
    }

    // TODO: - Remove when all POST bodies use Codable, instead of BTJSON/raw dictionaries
    func post(_ path: String, configuration: BTConfiguration? = nil, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping RequestCompletion) {
        httpRequest(method: "POST", path: path, configuration: configuration, parameters: parameters, headers: headers, completion: completion)
    }
    
    func post(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable, headers: [String: String]? = nil, completion: @escaping RequestCompletion) {
        do {
            let dict = try parameters.toDictionary()
            post(path, configuration: configuration, parameters: dict, headers: headers, completion: completion)
        } catch let error {
            completion(nil, nil, error)
        }
    }

    // MARK: - HTTP Method Helpers

    func httpRequest(
        method: String,
        path: String,
        configuration: BTConfiguration? = nil,
        parameters: [String: Any]? = [:],
        headers: [String: String]? = nil,
        completion: RequestCompletion?
    ) {
        do {
            let request = try createRequest(method: method, path: path, configuration: configuration, parameters: parameters, headers: headers)
            
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
        configuration: BTConfiguration? = nil,
        parameters: [String: Any]? = [:],
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
            errorUserInfo["method"] = method
            errorUserInfo["path"] = path
            errorUserInfo["parameters"] = parameters

            throw BTHTTPError.missingBaseURL(errorUserInfo)
        }
        
        let mutableParameters: NSMutableDictionary = NSMutableDictionary(dictionary: parameters ?? [:])

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
        method: String,
        url: URL,
        parameters: NSMutableDictionary? = [:],
        headers additionalHeaders: [String: String]? = nil
    ) throws -> URLRequest {
        guard var components: URLComponents = URLComponents(string: url.absoluteString) else {
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
        
        if authorization.type == .tokenizationKey {
            headers["Client-Key"] = authorization.originalValue
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
