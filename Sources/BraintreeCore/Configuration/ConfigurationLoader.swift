import Foundation

/// used to isolate `getConfig` to a singleton
@globalActor actor ConfigurationActor {
    static let shared = ConfigurationActor()
}

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache = ConfigurationCache.shared
    private let http: BTHTTP

    /// Used to hold an in-flight task to fetch a configuration or return an error
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
    /// - Returns: A `BTConfiguration` if it is successfully fetched or retrieved from the cache.
    /// - Throws: An `Error` describing the failure; if fetching the configuration fails or if the instance is deallocated.
    @_documentation(visibility: private)
    @ConfigurationActor
    func getConfig() async throws -> BTConfiguration {
        if let cachedConfig = try? configurationCache.getFromCache(authorization: http.authorization.bearer) {
            return cachedConfig
        }

        /// if we are writing to the cache at this time, we can return the existing task
        if let existingTask {
            return try await existingTask.value
        }

        existingTask = Task { [weak self] in
            guard let self else {
                throw BTAPIClientError.deallocated
            }

            /// clear out any existing task after current task is complete
            defer { existingTask = nil }

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

        guard let existingTask else {
            throw BTAPIClientError.configurationUnavailable
        }

        return try await existingTask.value
    }
}
