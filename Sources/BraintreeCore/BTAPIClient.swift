import Foundation

/// This class acts as the entry point for accessing the Braintree APIs via common HTTP methods performed on API endpoints.
/// - Note: It also manages authentication via tokenization key and provides access to a merchant's gateway configuration.
@objcMembers public class BTAPIClient: NSObject, BTHTTPNetworkTiming {

    /// :nodoc: This typealias is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    public typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Public Properties

    /// The TokenizationKey or ClientToken used to authorize the APIClient
    public var authorization: ClientAuthorization
    
    /// Client metadata that is used for tracking the client session
    public private(set) var metadata: BTClientMetadata

    // MARK: - Internal Properties
    
    var http: BTHTTP?
    var graphQLHTTP: BTGraphQLHTTP?
    var payPalHTTP: BTHTTP?

    /// Exposed for testing analytics
    /// By default, the `BTAnalyticsService` instance is static/shared so that only one queue of events exists.
    /// The "singleton" is managed here because the analytics service depends on `BTAPIClient`.
    weak var analyticsService: BTAnalyticsService? {
        get { BTAPIClient._analyticsService }
        set { BTAPIClient._analyticsService = newValue }
    }

    private static var _analyticsService: BTAnalyticsService?

    // MARK: - Initializers

    /// Initialize a new API client.
    /// - Parameter authorization: Your tokenization key or client token. Passing an invalid value may return `nil`.
    @objc(initWithAuthorization:)
    public convenience init?(authorization: String) {
        self.init(authorization: authorization, sendAnalyticsEvent: true)
    }

    init?(authorization: String, sendAnalyticsEvent: Bool) {
        self.metadata = BTClientMetadata()

        guard let authorizationType = Self.authorizationType(for: authorization) else { return nil }

        switch authorizationType {
        case .tokenizationKey:
            do {
                self.authorization =  try TokenizationKey(authorization)
                http = BTHTTP(authorization: self.authorization)
            } catch {
                return nil
            }
        case .clientToken:
            do {
                let clientToken = try BTClientToken(clientToken: authorization)
                self.authorization = clientToken

                http = BTHTTP(authorization: self.authorization)
            } catch {
                return nil
            }
        }
        
        super.init()
        BTAPIClient._analyticsService = BTAnalyticsService(apiClient: self)
        http?.networkTimingDelegate = self

        // Kickoff the background request to fetch the config
        fetchOrReturnRemoteConfiguration { configuration, error in
            // No-op
        }
    }

    // MARK: - Deinit

    deinit {
        if http != nil && http?.session != nil {
            http?.session.finishTasksAndInvalidate()
        }

        if graphQLHTTP != nil && graphQLHTTP?.session != nil {
            graphQLHTTP?.session.finishTasksAndInvalidate()
        }
    }

    // MARK: - Public Methods

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    ///  Provides configuration data as a `BTJSON` object.
    ///
    ///  The configuration data can be used by supported payment options to configure themselves
    ///  dynamically through the Control Panel. It also contains configuration options for the Braintree SDK Core components.
    /// - Parameter completion: Callback that returns either a `BTConfiguration` or `Error`
    /// - Note: This method is asynchronous because it requires a network call to fetch the
    /// configuration for a merchant account from Braintree servers. This configuration is
    /// cached on subsequent calls for better performance.
    @_documentation(visibility: private)
    public func fetchOrReturnRemoteConfiguration(_ completion: @escaping (BTConfiguration?, Error?) -> Void) {
        // Fetches or returns the configuration and caches the response in the GET BTHTTP call if successful
        //
        // Rules:
        //   - If cachedConfiguration is present, return it without a request
        //   - If cachedConfiguration is not present, fetch it and cache the successful response
        //   - If fetching fails, return error

        let configPath = "v1/configuration"
        
        if let cachedConfig = try? ConfigurationCache.shared.getFromCache(authorization: self.authorization.bearer) {
            setupHTTPCredentials(cachedConfig)
            completion(cachedConfig, nil)
            return
        }

        http?.get(configPath, parameters: BTConfigurationRequest()) { [weak self] body, response, error in
            guard let self else {
                completion(nil, BTAPIClientError.deallocated)
                return
            }

            if error != nil {
                completion(nil, error)
                return
            } else if response?.statusCode != 200 || body == nil {
                completion(nil, BTAPIClientError.configurationUnavailable)
                return
            } else {
                let configuration = BTConfiguration(json: body)

                setupHTTPCredentials(configuration)
                try? ConfigurationCache.shared.putInCache(authorization: authorization.bearer, configuration: configuration)
                
                completion(configuration, nil)
                return
            }
        }
    }
    
    func fetchConfiguration() async throws -> BTConfiguration {
        try await withCheckedThrowingContinuation { continuation in
            fetchOrReturnRemoteConfiguration { configuration, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let configuration {
                    continuation.resume(returning: configuration)
                }
            }
        }
    }

    /// Fetches a customer's vaulted payment method nonces.
    /// Must be using client token with a customer ID specified.
    ///  - Parameter completion: Callback that returns either an array of payment method nonces or an error
    ///  - Note: Only the top level `BTPaymentMethodNonce` type is returned, fetching any additional details will need to be done on the server
    public func fetchPaymentMethodNonces(_ completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        fetchPaymentMethodNonces(false, completion: completion)
    }

    // NEXT_MAJOR_VERSION: this should move into the Drop-in for parity with Android
    // This will also allow us to return the types directly which we were doing in the +load method
    // previously in Obj-C - this is not available in Swift
    /// Fetches a customer's vaulted payment method nonces.
    /// Must be using client token with a customer ID specified.
    ///  - Parameters:
    ///   - defaultFirst: Specifies whether to sort the fetched payment method nonces with the default payment method or the most recently used payment method first
    ///   - completion: Callback that returns either an array of payment method nonces or an error
    ///   - Note: Only the top level `BTPaymentMethodNonce` type is returned, fetching any additional details will need to be done on the server
    public func fetchPaymentMethodNonces(_ defaultFirst: Bool, completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        if authorization.type != .clientToken {
            completion(nil, BTAPIClientError.notAuthorized)
            return
        }

        let defaultFirstValue: String = defaultFirst ? "true" : "false"
        let parameters: [String: String] = [
            "default_first": defaultFirstValue,
            "session_id": metadata.sessionID
        ]

        get("v1/payment_methods", parameters: parameters) { body, response, error in
            if let error {
                completion(nil, error)
                return
            }

            var paymentMethodNonces: [BTPaymentMethodNonce] = []

            body?["paymentMethods"].asArray()?.forEach { paymentInfo in
                let type: String? = paymentInfo["type"].asString()
                let paymentMethodNonce: BTPaymentMethodNonce? = BTPaymentMethodNonceParser.shared.parseJSON(paymentInfo, withParsingBlockForType: type)

                if let paymentMethodNonce {
                    paymentMethodNonces.append(paymentMethodNonce)
                }
            }

            completion(paymentMethodNonces, nil)
        }
    }
    
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Perfom an HTTP GET on a URL composed of the configured from environment and the given path.
    /// - Parameters:
    ///   - path: The endpoint URI path.
    ///   - parameters: Optional set of query parameters to be encoded with the request.
    ///   - httpType: The underlying `BTAPIClientHTTPService` of the HTTP request. Defaults to `.gateway`.
    ///   - completion:  A block object to be executed when the request finishes.
    ///   On success, `body` and `response` will contain the JSON body response and the
    ///   HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
    ///   `nil` and `error` will contain the error that occurred.
    @_documentation(visibility: private)
    public func get(
        _ path: String,
        parameters: Encodable? = nil,
        httpType: BTAPIClientHTTPService = .gateway,
        completion: @escaping RequestCompletion
    ) {
        fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(nil, nil, BTAPIClientError.deallocated)
                return
            }

            if let error {
                completion(nil, nil, error)
                return
            }

            http(for: httpType)?.get(path, configuration: configuration, parameters: parameters, completion: completion)
        }
    }

    // TODO: - Remove when all POST bodies use Codable, instead of BTJSON/raw dictionaries
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Perfom an HTTP POST on a URL composed of the configured from environment and the given path.
    /// - Parameters:
    ///   - path: The endpoint URI path.
    ///   - parameters: Optional set of query parameters to be encoded with the request.
    ///   - httpType: The underlying `BTAPIClientHTTPService` of the HTTP request. Defaults to `.gateway`.
    ///   - completion:  A block object to be executed when the request finishes.
    ///   On success, `body` and `response` will contain the JSON body response and the
    ///   HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
    ///   `nil` and `error` will contain the error that occurred.
    @_documentation(visibility: private)
    @objc(POST:parameters:httpType:completion:)
    public func post(
        _ path: String,
        parameters: [String: Any]? = nil,
        httpType: BTAPIClientHTTPService = .gateway,
        completion: @escaping RequestCompletion
    ) {
        fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(nil, nil, BTAPIClientError.deallocated)
                return
            }

            if let error {
                completion(nil, nil, error)
                return
            }

            let postParameters = metadataParametersWith(parameters, for: httpType)
            http(for: httpType)?.post(path, configuration: configuration, parameters: postParameters, completion: completion)
        }
    }
    
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Perfom an HTTP POST on a URL composed of the configured from environment and the given path.
    /// - Parameters:
    ///   - path: The endpoint URI path.
    ///   - parameters: Optional set of query parameters to be encoded with the request.
    ///   - httpType: The underlying `BTAPIClientHTTPService` of the HTTP request. Defaults to `.gateway`.
    ///   - completion:  A block object to be executed when the request finishes.
    ///   On success, `body` and `response` will contain the JSON body response and the
    ///   HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
    ///   `nil` and `error` will contain the error that occurred.
    @_documentation(visibility: private)
    public func post(
        _ path: String,
        parameters: Encodable,
        headers: [String: String]? = nil,
        httpType: BTAPIClientHTTPService = .gateway,
        completion: @escaping RequestCompletion
    ) {
        fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(nil, nil, BTAPIClientError.deallocated)
                return
            }

            if let error {
                completion(nil, nil, error)
                return
            }

            let postParameters = BTAPIRequest(requestBody: parameters, metadata: metadata, httpType: httpType)
            http(for: httpType)?.post(path, configuration: configuration, parameters: postParameters, headers: headers, completion: completion)
        }
    }
    
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Perfom an HTTP POST on a URL composed of the configured from environment and the given path.
    /// - Parameters:
    ///   - path: The endpoint URI path.
    ///   - parameters: Optional set of query parameters to be encoded with the request.
    ///   - httpType: The underlying `BTAPIClientHTTPService` of the HTTP request. Defaults to `.gateway`.
    /// - Returns: On success, `(BTJSON?, HTTPURLResponse?)` will contain the JSON body response and the HTTP response.
    @_documentation(visibility: private)
    public func post(
        _ path: String,
        parameters: Encodable,
        headers: [String: String]? = nil,
        httpType: BTAPIClientHTTPService = .gateway
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            post(path, parameters: parameters, headers: headers, httpType: httpType) { json, httpResonse, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (json, httpResonse))
                }
            }
        }
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    public func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        isVaultRequest: Bool? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil
    ) {
        analyticsService?.sendAnalyticsEvent(
            eventName,
            correlationID: correlationID,
            errorDescription: errorDescription,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
    }

    // MARK: Analytics Internal Methods

    // TODO: - Remove once all POSTs moved to Encodable
    func metadataParametersWith(_ parameters: [String: Any]? = [:], for httpType: BTAPIClientHTTPService) -> [String: Any]? {
        switch httpType {
        case .gateway:
            return parameters?.merging(["_meta": metadata.parameters]) { $1 }
        case .graphQLAPI:
            return parameters?.merging(["clientSdkMetadata": metadata.parameters]) { $1 }
        case .payPalAPI:
            return parameters
        }
    }

    // MARK: - Internal Static Methods

    static func authorizationType(for authorization: String) -> AuthorizationType? {
        let pattern: String = "([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else { return nil }

        let tokenizationKeyMatch: NSTextCheckingResult? = regularExpression.firstMatch(in: authorization, options: [], range: NSRange(location: 0, length: authorization.count))

        return tokenizationKeyMatch != nil ? .tokenizationKey : .clientToken
    }
    
    // MARK: - Internal Methods

    func http(for httpType: BTAPIClientHTTPService) -> BTHTTP? {
        switch httpType {
        case .gateway:
            return http
        case .graphQLAPI:
            return graphQLHTTP
        case .payPalAPI:
            return payPalHTTP
        }
    }
    
    // MARK: - Private Methods
    
    private func setupHTTPCredentials(_ configuration: BTConfiguration) {
        if http == nil {
            http = BTHTTP(authorization: authorization)
            http?.networkTimingDelegate = self
        }

        if graphQLHTTP == nil {
            graphQLHTTP = BTGraphQLHTTP(authorization: authorization)
            graphQLHTTP?.networkTimingDelegate = self
        }
        
        if payPalHTTP == nil {
            let paypalBaseURL: URL? = payPalAPIURL(forEnvironment: configuration.environment ?? "")
            
            if authorization.type == .clientToken {
                payPalHTTP = BTHTTP(authorization: authorization, customBaseURL: paypalBaseURL)
                payPalHTTP?.networkTimingDelegate = self
            }
        }
    }
    
    func payPalAPIURL(forEnvironment environment: String) -> URL? {
        if environment.caseInsensitiveCompare("sandbox") == .orderedSame ||
            environment.caseInsensitiveCompare("development") == .orderedSame {
            return BTCoreConstants.payPalSandboxURL
        } else {
            return BTCoreConstants.payPalProductionURL
        }
    }

    // MARK: BTAPITimingDelegate conformance

    func fetchAPITiming(path: String, startTime: Int, endTime: Int) {
        let cleanedPath = path.replacingOccurrences(of: "/merchants/([A-Za-z0-9]+)/client_api", with: "", options: .regularExpression)

        if cleanedPath != "/v1/tracking/batch/events" {
            analyticsService?.sendAnalyticsEvent(
                BTCoreAnalytics.apiRequestLatency,
                endpoint: cleanedPath,
                endTime: endTime,
                startTime: startTime
            )
        }
    }
}
