
protocol ConfigurationLoadable {
    func getConfiguration() async throws -> BTConfiguration
}

final class ConfigurationLoader: ConfigurationLoadable {
    
    public var authorization: ClientAuthorization
    private var cache = ConfigurationCache.shared
    private lazy var http: BTHTTP? = BTHTTP(authorization: authorization)
    
    init(authorization: ClientAuthorization) {
        self.authorization = authorization
    }
    
    func getConfiguration() async throws -> BTConfiguration {
        try await withCheckedThrowingContinuation { continuation in
            let configPath = "v1/configuration"
            
            if let cachedConfig = try? ConfigurationCache.shared.getFromCache(authorization: self.authorization.bearer) {
                continuation.resume(returning: cachedConfig)
                return
            }
            
            http?.get(configPath, parameters: BTConfigurationRequest()) { [weak self] body, response, error in
                guard let self else {
                    continuation.resume(throwing: BTAPIClientError.deallocated)
                    return
                }

                if error != nil {
                    continuation.resume(throwing: error!)
                } else if response?.statusCode != 200 || body == nil {
                    continuation.resume(throwing: BTAPIClientError.configurationUnavailable)
                } else {
                    let configuration = BTConfiguration(json: body)

                    try? ConfigurationCache.shared.putInCache(authorization: authorization.bearer, configuration: configuration)
                    
                    continuation.resume(returning: configuration)
                }
            }
        }
    }
}
