import Foundation

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache: ConfigurationCache = ConfigurationCache.shared
    private let http: BTHTTP
    
    // MARK: - Intitializer
    
    init(http: BTHTTP) {
        self.http = http
    }
    
    deinit {
        http.session.finishTasksAndInvalidate()
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
    ///   - authorization: An `ClientAuthorization` object required to access the configuration.
    ///   - completion: A completion handler that is called with the fetched or cached `BTConfiguration` object or an `Error`.
    ///
    /// - Completion:
    ///   - `BTConfiguration?`: The configuration object if it is successfully fetched or retrieved from the cache.
    ///   - `Error?`: An error object if fetching the configuration fails or if the instance is deallocated.
    @_documentation(visibility: private)
    func getConfig(_ authorization: ClientAuthorization, completion: @escaping (BTConfiguration?, Error?) -> Void) {
        if let cachedConfig = try? configurationCache.getFromCache(authorization: authorization.bearer) {
            completion(cachedConfig, nil)
            return
        }

        http.get(configPath, parameters: BTConfigurationRequest()) { [weak self] body, response, error in
            guard let self else {
                completion(nil, BTAPIClientError.deallocated)
                return
            }

            if let error {
                completion(nil, error)
                return
            } else if response?.statusCode != 200 || body == nil {
                completion(nil, BTAPIClientError.configurationUnavailable)
                return
            } else {
                let configuration = BTConfiguration(json: body)

                try? configurationCache.putInCache(authorization: authorization.bearer, configuration: configuration)
                
                completion(configuration, nil)
                return
            }
        }
    }
    
    func getConfig(_ authorization: ClientAuthorization) async throws -> BTConfiguration {
        try await withCheckedThrowingContinuation { continuation in
            getConfig(authorization) { configuration, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let configuration {
                    continuation.resume(returning: configuration)
                }
            }
        }
    }
}
