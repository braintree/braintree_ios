import Foundation

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache = ConfigurationCache.shared
    private let http: BTHTTP
    private let pendingCompletions = ConfigurationCallbackStorage()
    private var isConfigCached = false // TODO: - Rename; should this bool live here?

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
        
        pendingCompletions.add(completion)
        
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
        if let cachedConfig = try? configurationCache.getFromCache(authorization: http.authorization.bearer) {
            isConfigCached = true
            return cachedConfig
        }
     
        while !isConfigCached {
            print("While loop body")
            
            do {
                print("🤞GET request made")
                let (body, response) = try await http.get(configPath, parameters: BTConfigurationRequest())
                
                if response.statusCode != 200 { // || body == nil {
                    throw BTAPIClientError.configurationUnavailable
                } else {
                    let configuration = BTConfiguration(json: body)
                    
                    try? configurationCache.putInCache(authorization: http.authorization.bearer, configuration: configuration)
                    
                    NotificationCenter.default.post(name: Notification.Name("ConfigGet"), object: configuration)
                    isConfigCached = true

                    return configuration
                }
            } catch {
                throw error
            }
        }
        print("Exited while loop")
        throw BTAPIClientError.configurationUnavailable
    }
    
    // MARK: - Private Methods
    
    func notifyCompletions(_ configuration: BTConfiguration?, _ error: Error?) {
        pendingCompletions.invoke(configuration, error)
    }
}
