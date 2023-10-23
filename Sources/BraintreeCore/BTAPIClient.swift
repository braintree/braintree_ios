import Foundation

/// This class acts as the entry point for accessing the Braintree APIs via common HTTP methods performed on API endpoints.
/// - Note: It also manages authentication via tokenization key and provides access to a merchant's gateway configuration.
@objcMembers public class BTAPIClient: NSObject {

    /// :nodoc: This typealias is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    public typealias RequestCompletion = (BTJSON?, HTTPURLResponse?, Error?) -> Void

    // MARK: - Public Properties

    /// The tokenization key used to authorize the APIClient
    public var tokenizationKey: String?

    /// The client token used to authorize the APIClient
    public var clientToken: BTClientToken?

    /// Client metadata that is used for tracking the client session
    public private(set) var metadata: BTClientMetadata

    // MARK: - Internal Properties

    /// Used to fetch and store configurations in the URL Cache of the session
    var configurationHTTP: BTHTTP?

    var http: BTHTTP?
    var apiHTTP: BTAPIHTTP?
    var graphQLHTTP: BTGraphQLHTTP?

    var session: URLSession {
        let configurationQueue: OperationQueue = OperationQueue()
        configurationQueue.name = "com.braintreepayments.BTAPIClient"

        // BTHTTP's default NSURLSession does not cache responses, but we want the BTHTTP instance that fetches configuration to cache aggressively
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let configurationCache: URLCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, diskPath: nil)

        configuration.urlCache = configurationCache

        // Use the caching logic defined in the protocol implementation, if any, for a particular URL load request.
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }

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
    /// - Parameter authorization: Your tokenization key, client token, or PayPal ID Token. Passing an invalid value may return `nil`.
    @objc(initWithAuthorization:)
    public convenience init?(authorization: String) {
        self.init(authorization: authorization, sendAnalyticsEvent: true)
    }

    init?(authorization: String, sendAnalyticsEvent: Bool) {
        self.metadata = BTClientMetadata()

        super.init()
        BTAPIClient._analyticsService = BTAnalyticsService(apiClient: self, flushThreshold: 5)
        guard let authorizationType: BTAPIClientAuthorization = Self.authorizationType(forAuthorization: authorization) else { return nil }

        let errorString = BTLogLevelDescription.string(for: .error) 

        switch authorizationType {
        case .tokenizationKey:
            let baseURL: URL? = Self.baseURLFromTokenizationKey(authorization)

            guard let baseURL else {
                let reason: String = "BTClient could not initialize because the provided tokenization key was invalid"
                print(errorString + " Missing analytics session metadata - will not send event " + reason)
                return nil
            }

            tokenizationKey = authorization
            configurationHTTP = BTHTTP(url: baseURL, tokenizationKey: authorization)
        case .clientToken:
            do {
                clientToken = try BTClientToken(clientToken: authorization)

                guard let clientToken else { return nil }
                configurationHTTP = try BTHTTP(clientToken: clientToken)
            } catch {
                print(errorString + " Missing analytics session metadata - will not send event " + error.localizedDescription)
                return nil
            }
        }

        configurationHTTP?.session = session

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

        if apiHTTP != nil && apiHTTP?.session != nil {
            apiHTTP?.session.finishTasksAndInvalidate()
        }

        if graphQLHTTP != nil && graphQLHTTP?.session != nil {
            graphQLHTTP?.session.finishTasksAndInvalidate()
        }

        configurationHTTP?.session.configuration.urlCache?.removeAllCachedResponses()
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

        var configPath: String = "v1/configuration"
        var configuration: BTConfiguration?

        if let clientToken {
            configPath = clientToken.configURL.absoluteString
        }

        let parameters: [String: Any] = ["configVersion": "3"]

        configurationHTTP?.get(configPath, parameters: parameters, shouldCache: true) { [weak self] body, response, error in
            guard let self else {
                completion(nil, BTAPIClientError.deallocated)
                return
            }

            if error != nil {
                completion(nil, error)
                return
            } else if response?.statusCode != 200 {
                completion(nil, BTAPIClientError.configurationUnavailable)
                return
            } else {
                configuration = BTConfiguration(json: body)

                if apiHTTP == nil {
                    let apiURL: URL? = configuration?.json?["clientApiUrl"].asURL()
                    let accessToken: String? = configuration?.json?["braintreeApi"]["accessToken"].asString()

                    if let apiURL, let accessToken {
                        apiHTTP = BTAPIHTTP(url: apiURL, accessToken: accessToken)
                    }
                }

                if http == nil {
                    let baseURL: URL? = configuration?.json?["clientApiUrl"].asURL()

                    if let clientToken, let baseURL {
                        http = BTHTTP(url: baseURL, authorizationFingerprint: clientToken.authorizationFingerprint)
                    } else if let tokenizationKey, let baseURL {
                        http = BTHTTP(url: baseURL, tokenizationKey: tokenizationKey)
                    }
                }

                if graphQLHTTP == nil {
                    let graphQLBaseURL: URL? = graphQLURL(forEnvironment: configuration?.environment ?? "")

                    if let clientToken, let graphQLBaseURL {
                        graphQLHTTP = BTGraphQLHTTP(url: graphQLBaseURL, authorizationFingerprint: clientToken.authorizationFingerprint)
                    } else if let tokenizationKey, let graphQLBaseURL {
                        graphQLHTTP = BTGraphQLHTTP(url: graphQLBaseURL, tokenizationKey: tokenizationKey)
                    }
                }
            }

            completion(configuration, nil)
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
        if clientToken == nil {
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
    ///   - completion:  A block object to be executed when the request finishes.
    ///   On success, `body` and `response` will contain the JSON body response and the
    ///   HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
    ///   `nil` and `error` will contain the error that occurred.
    @_documentation(visibility: private)
    @objc(GET:parameters:completion:)
    public func get(_ path: String, parameters: [String: String]? = nil, completion: @escaping RequestCompletion) {
        get(path, parameters: parameters, httpType: .gateway, completion: completion)
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Perfom an HTTP POST on a URL composed of the configured from environment and the given path.
    /// - Parameters:
    ///   - path: The endpoint URI path.
    ///   - parameters: Optional set of query parameters to be encoded with the request.
    ///   - completion:  A block object to be executed when the request finishes.
    ///   On success, `body` and `response` will contain the JSON body response and the
    ///   HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
    ///   `nil` and `error` will contain the error that occurred.
    @_documentation(visibility: private)
    @objc(POST:parameters:completion:)
    public func post(_ path: String, parameters: [String: Any]? = nil, completion: @escaping RequestCompletion) {
        post(path, parameters: parameters, httpType: .gateway, completion: completion)
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    @objc(GET:parameters:httpType:completion:)
    public func get(_ path: String, parameters: [String: String]? = nil, httpType: BTAPIClientHTTPService, completion: @escaping RequestCompletion) {
        fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else {
                completion(nil, nil, BTAPIClientError.deallocated)
                return
            }

            if let error {
                completion(nil, nil, error)
                return
            }

            http(for: httpType)?.get(path, parameters: parameters, completion: completion)
        }
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    @objc(POST:parameters:httpType:completion:)
    public func post(_ path: String, parameters: [String: Any]? = nil, httpType: BTAPIClientHTTPService, completion: @escaping RequestCompletion) {
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
            http(for: httpType)?.post(path, parameters: postParameters, completion: completion)
        }
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    @_documentation(visibility: private)
    public func sendAnalyticsEvent(_ eventName: String, errorDescription: String? = nil, correlationID: String? = nil) {
        analyticsService?.sendAnalyticsEvent(
            eventName,
            errorDescription: errorDescription,
            correlationID: correlationID,
            completion: { _ in }
        )
    }

    // MARK: Analytics Internal Methods

    func metadataParametersWith(_ parameters: [String: Any]? = [:], for httpType: BTAPIClientHTTPService) -> [String: Any]? {
        switch httpType {
        case .gateway:
            return parameters?.merging(["_meta": metadata.parameters]) { $1 }
        case .braintreeAPI:
            return parameters
        case .graphQLAPI:
            return parameters?.merging(["clientSdkMetadata": metadata.parameters]) { $1 }
        }
    }

    // MARK: - Internal Static Methods

    static func baseURLFromTokenizationKey(_ tokenizationKey: String) -> URL? {
        let pattern: String = "([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(location: 0, length: tokenizationKey.count)
        let matches = regularExpression.matches(in: tokenizationKey, range: range)

        if matches.count != 1 || matches.first?.numberOfRanges != 3 {
            return nil
        }

        var environment: String = ""
        var merchantID: String = ""

        matches.forEach { match in
            environment = (tokenizationKey as NSString).substring(with: match.range(at: 1))
            merchantID = (tokenizationKey as NSString).substring(with: match.range(at: 2))
        }

        var components: URLComponents = URLComponents()
        components.scheme = scheme(forEnvironment: environment)

        guard let host = host(forEnvironment: environment, httpType: .gateway) else { return nil }
        let hostComponents: [String] = host.components(separatedBy: ":")

        components.host = hostComponents.first

        if hostComponents.count > 1 {
            let portString: String = hostComponents[1]
            components.port = Int(portString)
        }

        components.path = clientApiBasePath(forMerchantID: merchantID)

        return components.url
    }

    static func authorizationType(forAuthorization authorization: String) -> BTAPIClientAuthorization? {
        let pattern: String = "([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else { return nil }

        let tokenizationKeyMatch: NSTextCheckingResult? = regularExpression.firstMatch(in: authorization, options: [], range: NSRange(location: 0, length: authorization.count))

        return tokenizationKeyMatch != nil ? .tokenizationKey : .clientToken
    }

    static func scheme(forEnvironment environment: String) -> String {
        environment.lowercased() == "development" ? "http" : "https"
    }

    static func host(forEnvironment environment: String, httpType: BTAPIClientHTTPService) -> String? {
        var host: String? = nil
        let environmentLowercased: String = environment.lowercased()

        switch httpType {
        case .gateway:
            if environmentLowercased == "sandbox" {
                host = "api.sandbox.braintreegateway.com"
            } else if environmentLowercased == "production" {
                host = "api.braintreegateway.com:443"
            } else if environmentLowercased == "development" {
                host = "localhost:3000"
            }

        case .graphQLAPI:
            if environmentLowercased == "sandbox" {
                host = "payments.sandbox.braintree-api.com"
            } else if environmentLowercased == "development" {
                host = "localhost:8080"
            } else {
                host = "payments.braintree-api.com"
            }

        default:
            host = nil
        }

        return host
    }

    static func clientApiBasePath(forMerchantID merchantID: String) -> String {
        "/merchants/\(merchantID)/client_api"
    }

    // MARK: - Internal Methods

    func graphQLURL(forEnvironment environment: String) -> URL? {
        var components: URLComponents = URLComponents()
        components.scheme = Self.scheme(forEnvironment: environment)

        guard let host: String = Self.host(forEnvironment: environment, httpType: .graphQLAPI) else { return nil }
        let hostComponents: [String] = host.components(separatedBy: ":")

        if hostComponents.count == 0 {
            return nil
        }

        components.host = hostComponents.first

        if hostComponents.count > 1 {
            let portString: String = hostComponents[1]
            components.port = Int(portString)
        }

        components.path = "/graphql"
        return components.url
    }

    func http(for httpType: BTAPIClientHTTPService) -> BTHTTP? {
        switch httpType {
        case .gateway:
            return http
        case .braintreeAPI:
            return apiHTTP
        case .graphQLAPI:
            return graphQLHTTP
        }
    }
}
