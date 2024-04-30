import Foundation

struct BTURLCacheManager {
    
    // MARK: - Private Properties
    
    private let timeToLiveMinutes: Double = 5
    private let dateFormatter: DateFormatter = DateFormatter()
    private let cacheInstance: URLCacheable
    
    // MARK: - Init
        
    /// Exposed for testing, injection of URLCache mock.
    init(cache: URLCacheable = URLCache.shared) {
        self.cacheInstance = cache
    }
    
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
