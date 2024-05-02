import Foundation

class ConfigurationCache {
        
    // MARK: - Private Properties
    
    private let timeToLiveMinutes = 5.0
    
    // MARK: - Internal Properties
    
    /// Exposed for testing
    let cacheInstance = NSCache<NSString, BTConfiguration>()

    // MARK: - Singleton Setup
    
    static let shared = ConfigurationCache()
    private init() { }
    
    // MARK: - Internal Methods
    
    func putInCache(authorization: String, configuration: BTConfiguration) throws {
        let cacheKey = try createCacheKey(authorization)
        cacheInstance.setObject(configuration, forKey: cacheKey)
    }
    
    func getFromCache(authorization: String) throws -> BTConfiguration? {
        let cacheKey = try createCacheKey(authorization)
        guard let cachedConfig = cacheInstance.object(forKey: cacheKey) else {
            return nil
        }
        
        let timeInCache = Date().timeIntervalSince1970 - cachedConfig.time
        if timeInCache < (timeToLiveMinutes * 60) {
            return cachedConfig
        } else {
            cacheInstance.removeObject(forKey: cacheKey)
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func createCacheKey(_ authorization: String) throws -> NSString {
        if let data = authorization.data(using: .utf8) {
            return data.base64EncodedString() as NSString
        } else {
            throw BTAPIClientError.failedBase64Encoding
        }
    }
}
