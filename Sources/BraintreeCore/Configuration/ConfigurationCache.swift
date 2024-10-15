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
    
    /// Adds a configuration object to the cache.
    /// - Parameters:
    ///   - authorization: An authorizationFingerprint or tokenizationKey.
    ///   - configuration: A `BTConfiguration` object.
    /// - Throws: An error if the authorization string cannot be base64 encoded for cache entry.
    func putInCache(authorization: String, configuration: BTConfiguration) throws {
        let cacheKey = try createCacheKey(authorization)
        cacheInstance.setObject(configuration, forKey: cacheKey)
    }
    
    /// Checks to see if a configuration object exists in the cache for a given authorization string.
    /// - Parameter authorization: An authorizationFingerprint or tokenizationKey.
    /// - Returns: A `BTConfiguration` object if present in the cache, or `nil` if not present in the cache.
    /// - Throws: An error if the authorization string cannot be base64 encoded for cache lookup.
    func getFromCache(authorization: String) throws -> BTConfiguration? {
        let cacheKey = try createCacheKey(authorization)
        guard let cachedConfig = cacheInstance.object(forKey: cacheKey) else {
            return nil
        }
        
        let timeInCache = Date().timeIntervalSince1970 - cachedConfig.time
        if timeInCache < (timeToLiveMinutes * 60) {
            cachedConfig.isFromCache = true
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
