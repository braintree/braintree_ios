import Foundation

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache = ConfigurationCache.shared
    private let http: BTHTTP

    private var existingTask: Task<BTConfiguration, Error>?

    // MARK: - Initializer
    
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
    ///   - completion: A completion handler that is called with the fetched or cached `BTConfiguration` object or an `Error`.
    ///
    /// - Completion:
    ///   - `BTConfiguration?`: The configuration object if it is successfully fetched or retrieved from the cache.
    ///   - `Error?`: An error object if fetching the configuration fails or if the instance is deallocated.
    @_documentation(visibility: private)
    func getConfig() async throws -> BTConfiguration {
        if let cachedConfig = try? configurationCache.getFromCache(authorization: http.authorization.bearer) {
            return cachedConfig
        }
        
        if let existingTask {
            return try await existingTask.value
        }
     
        let task = Task { [weak self] in
            guard let self else {
                throw BTAPIClientError.deallocated
            }

            defer { self.existingTask = nil }
            do {
                let (body, response) = try await http.get(configPath, parameters: BTConfigurationRequest())

                if response?.statusCode != 200 || body == nil {
                    throw BTAPIClientError.configurationUnavailable
                } else {
                    let configuration = BTConfiguration(json: body)
                    try? configurationCache.putInCache(authorization: http.authorization.bearer, configuration: configuration)
                    return configuration
                }
            } catch {
                throw error
            }
        }

        existingTask = task
        return try await task.value
    }
}
