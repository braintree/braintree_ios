import Foundation

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache: ConfigurationCache = ConfigurationCache.shared
    private let http: BTHTTP
    private var pendingCompletions: [(BTConfiguration?, Error?) -> Void] = []
        
    // MARK: - Intitializer
    
    init(http: BTHTTP) {
        self.http = http
    }
    
    deinit {
        http.session.finishTasksAndInvalidate()
        pendingCompletions.removeAll()
    }
    
    // MARK: - Internal Methods
        
    /// Fetches or returns the configuration and caches the response in the GET BTHTTP call if successful.
    ///
    /// This method attempts to retrieve the configuration in the following order:
    /// 1. If a cached configuration is available, it returns the cached configuration without making a network request.
    /// 2. If no cached configuration is found, it fetches the configuration from the server and caches the successful response.
    /// 3. If fetching the configuration fails, it returns an error.
    ///
    /// - Parameters:
    ///   - completion: A completion handler that is called with the fetched or cached `BTConfiguration` object or an `Error`.
    ///
    /// - Completion:
    ///   - `BTConfiguration?`: The configuration object if it is successfully fetched or retrieved from the cache.
    ///   - `Error?`: An error object if fetching the configuration fails or if the instance is deallocated.
    @_documentation(visibility: private)
    func getConfig(completion: @escaping (BTConfiguration?, Error?) -> Void) {
        if let cachedConfig = try? configurationCache.getFromCache(authorization: http.authorization.bearer) {
            completion(cachedConfig, nil)
            return
        }
        
        pendingCompletions.append(completion)
        
        // If this is the 1st `v1/config` GET attempt, proceed with firing the network request.
        // Otherwise, there is already a pending network request.
        if pendingCompletions.count == 1 {
            http.get(configPath, parameters: BTConfigurationRequest()) { [weak self] body, response, error in
                guard let self else {
                    self?.notifyCompletions(nil, BTAPIClientError.deallocated)
                    return
                }

                if let error {
                    notifyCompletions(nil, error)
                    return
                } else if response?.statusCode != 200 || body == nil {
                    notifyCompletions(nil, BTAPIClientError.configurationUnavailable)
                    return
                } else {
                    let configuration = BTConfiguration(json: body)

                    try? configurationCache.putInCache(authorization: http.authorization.bearer, configuration: configuration)
                    
                    notifyCompletions(configuration, nil)
                    return
                }
            }
        }
    }
    
    func getConfig() async throws -> BTConfiguration {
        try await withCheckedThrowingContinuation { continuation in
            getConfig() { configuration, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let configuration {
                    continuation.resume(returning: configuration)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    func notifyCompletions(_ configuration: BTConfiguration?, _ error: Error?) {
        pendingCompletions.forEach { $0(configuration, error) }
        pendingCompletions.removeAll()
    }
}
