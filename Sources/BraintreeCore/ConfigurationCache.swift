import Foundation

class ConfigurationCache {
        
    // MARK: - Private Properties
    
    private let timeToLiveMinutes = 5.0
    
    // MARK: - Internal Properties
    
    /// Exposed for testing
    var cachedConfigStorage: [String: BTConfiguration] = [:]

    // MARK: - Singleton Setup
    
    static let shared = ConfigurationCache()
    private init() { }
    
    // MARK: - Internal Methods
    
    func putInCache(authorization: String, configuration: BTConfiguration) throws {
        let cacheKey = try createCacheKey(authorization)
        cachedConfigStorage[cacheKey] = configuration
    }
    
    func getFromCache(authorization: String) throws -> BTConfiguration? {
        let cacheKey = try createCacheKey(authorization)
        guard let cachedConfig = cachedConfigStorage[cacheKey] else {
            return nil
        }
        
        let timeInCache = Date().timeIntervalSince1970 - cachedConfig.time
        if timeInCache < timeToLiveMinutes {
            return cachedConfig
        } else {
            cachedConfigStorage.removeValue(forKey: cacheKey)
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func createCacheKey(_ authorization: String) throws -> String {       
        if let data = authorization.data(using: .utf8) {
            return data.base64EncodedString()
        } else {
            throw BTAPIClientError.failedBase64Encoding
        }
    }
}
