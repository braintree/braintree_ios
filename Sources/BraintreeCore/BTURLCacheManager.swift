import Foundation

class ConfigurationCache {
    
    static let shared = ConfigurationCache()
    
    private let timeToLiveMinutes = 5.0

    var cachedConfigStorage: [String: BTConfiguration] = [:]

    private init() { }
    
    func putInCache(authorization: String, configuration: BTConfiguration) throws {
        let cacheKey = try createCacheKey(authorization)
        cachedConfigStorage[cacheKey] = configuration
    }
    
    // TODO use auth type enum
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
    
    private func createCacheKey(_ authorization: String) throws -> String {
        if let data = authorization.data(using: .utf8) {
            return data.base64EncodedString()
        } else {
            throw BTClientTokenError.invalidAuthorizationFingerprint // TODO add specific error here
        }
    }
    
    private func isCacheItemValid() {}
}

struct BTURLCacheManager {
    
    // MARK: - Private Properties
    
    private let timeToLiveMinutes: Double = 5
    private let dateFormatter: DateFormatter = DateFormatter()
    
    /// Exposed for testing
    let cacheInstance = URLCache.shared
    
    // MARK: Internal Methods
    
    func getFromCache(request: URLRequest) -> CachedURLResponse? {
        if let cachedResponse = cacheInstance.cachedResponse(for: request) {
            if isItemExpired(cachedResponse) {
                cacheInstance.removeAllCachedResponses()
                return nil
            }
            return cachedResponse
        } else {
            return nil
        }
    }
        
    func putInCache(request: URLRequest, response: URLResponse, data: Data, statusCode: Int) {
        if statusCode >= 200 && statusCode < 300 {
            let cachedURLResponse = CachedURLResponse(response: response, data: data)
            cacheInstance.storeCachedResponse(cachedURLResponse, for: request)
        }
    }
    
    // MARK: - Private Methods

    /// Cached items over 5 minutes old are invalid
    private func isItemExpired(_ cachedResponse: CachedURLResponse) -> Bool {
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"

        let expirationTimestamp = Date().addingTimeInterval(-60 * timeToLiveMinutes)

        guard let cachedResponse = cachedResponse.response as? HTTPURLResponse,
              let cachedResponseDateString = cachedResponse.value(forHTTPHeaderField: "Date"),
              let cachedResponseTimestamp: Date = dateFormatter.date(from: cachedResponseDateString)
        else {
            return true
        }
        
        return expirationTimestamp >= cachedResponseTimestamp
    }
}
