import Foundation

class ConfigurationLoader {
    
    // MARK: - Private Properties
    
    private let configPath = "v1/configuration"
    private let configurationCache: ConfigurationCache = ConfigurationCache.shared
    private let http: BTHTTP
    
    init(http: BTHTTP) {
        self.http = http
    }
    
    deinit {
        http.session.finishTasksAndInvalidate()
    }
    
    func getConfig(_ authorization: ClientAuthorization, completion: @escaping (BTConfiguration?, Error?) -> Void) {
        // Fetches or returns the configuration and caches the response in the GET BTHTTP call if successful
        //
        // Rules:
        //   - If cachedConfiguration is present, return it without a request
        //   - If cachedConfiguration is not present, fetch it and cache the successful response
        //   - If fetching fails, return error
        
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
