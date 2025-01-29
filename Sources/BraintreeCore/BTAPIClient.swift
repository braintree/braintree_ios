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
    var configurationLoader: ConfigurationLoader
    
    /// Exposed for testing analytics
    var analyticsService: AnalyticsSendable = BTAnalyticsService.shared

    // MARK: - Initializers

    /// Initialize a new API client.
    /// - Parameter authorization: Your tokenization key or client token. Passing an invalid value may return `nil`.
    @objc(initWithAuthorization:)
    public init?(authorization: String) {
        self.metadata = BTClientMetadata()

        guard let authorizationType = Self.authorizationType(for: authorization) else { return nil }

        switch authorizationType {
        case .tokenizationKey:
            do {
                self.authorization = try TokenizationKey(authorization)
            } catch {
                return nil
            }
        case .clientToken:
            do {
                let clientToken = try BTClientToken(clientToken: authorization)
                self.authorization = clientToken
            } catch {
                return nil
            }
        }
        
        let btHttp = BTHTTP(authorization: self.authorization)
        http = btHttp
        configurationLoader = ConfigurationLoader(http: btHttp)
        
        super.init()
        analyticsService.setAPIClient(self)
        http?.networkTimingDelegate = self

        // Kickoff the background request to fetch the config
        fetchOrReturnRemoteConfiguration { _, _ in
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
        // TODO: - Consider updating all feature clients to use async version of this method?

        Task { @MainActor in
            do {
                let configuration = try await configurationLoader.getConfig()
                setupHTTPCredentials(configuration)
                completion(configuration, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    @MainActor func fetchConfiguration() async throws -> BTConfiguration {
        try await configurationLoader.getConfig()
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
            http(for: httpType)?.post(
                path,
                configuration: configuration,
                parameters: postParameters,
                headers: headers,
                completion: completion
            )
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
            post(path, parameters: parameters, headers: headers, httpType: httpType) { json, httpResponse, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (json, httpResponse))
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
        merchantExperiment: String? = nil,
        isConfigFromCache: Bool? = nil,
        isVaultRequest: Bool? = nil,
        linkType: LinkType? = nil,
        paymentMethodsDisplayed: String? = nil,
        payPalContextID: String? = nil,
        appSwitchURL: URL? = nil
    ) {
        analyticsService.sendAnalyticsEvent(
            FPTIBatchData.Event(
                appSwitchURL: appSwitchURL,
                correlationID: correlationID,
                errorDescription: errorDescription,
                eventName: eventName,
                isConfigFromCache: isConfigFromCache,
                isVaultRequest: isVaultRequest,
                linkType: linkType?.rawValue,
                merchantExperiment: merchantExperiment,
                paymentMethodsDisplayed: paymentMethodsDisplayed,
                payPalContextID: payPalContextID
            )
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

        let tokenizationKeyMatch: NSTextCheckingResult? = regularExpression.firstMatch(
            in: authorization,
            options: [],
            range: NSRange(location: 0, length: authorization.count)
        )

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
    
    private func setupHTTPCredentials(_ configuration: BTConfiguration?) {
        if graphQLHTTP == nil {
            graphQLHTTP = BTGraphQLHTTP(authorization: authorization)
            graphQLHTTP?.networkTimingDelegate = self
        }
        
        if payPalHTTP == nil {
            let paypalBaseURL: URL? = payPalAPIURL(forEnvironment: configuration?.environment ?? "")
            
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

    func fetchAPITiming(path: String, connectionStartTime: Int?, requestStartTime: Int?, startTime: Int, endTime: Int) {
        var cleanedPath = path.replacingOccurrences(of: "/merchants/([A-Za-z0-9]+)/client_api", with: "", options: .regularExpression)
        cleanedPath = cleanedPath.replacingOccurrences(
            of: "payment_methods/.*/three_d_secure",
            with: "payment_methods/three_d_secure",
            options: .regularExpression
        )
        
        if cleanedPath != "/v1/tracking/batch/events" {
            analyticsService.sendAnalyticsEvent(
                FPTIBatchData.Event(
                    connectionStartTime: connectionStartTime,
                    endpoint: cleanedPath,
                    endTime: endTime,
                    eventName: BTCoreAnalytics.apiRequestLatency,
                    requestStartTime: requestStartTime,
                    startTime: startTime
                )
            )
        }
    }
}
