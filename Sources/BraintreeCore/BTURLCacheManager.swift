import Foundation

struct BTURLCacheManager {
    
    private let timeToLiveMinutes: Double = 5
    private let dateFormatter: DateFormatter = DateFormatter()
    private let cacheInstance = URLCache.shared
    
    func getFromCache(request: URLRequest) -> CachedURLResponse? {
        if let cachedResponse = cacheInstance.cachedResponse(for: request) {
            if isCacheInvalid(cachedResponse) {
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
            URLCache.shared.storeCachedResponse(cachedURLResponse, for: request)
        }
    }

    private func isCacheInvalid(_ cachedConfigurationResponse: CachedURLResponse) -> Bool {
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"

        // Invalidate cached configuration after 5 minutes
        let expirationTimestamp: Date = Date().addingTimeInterval(-60 * timeToLiveMinutes)

        guard let cachedResponse = cachedConfigurationResponse.response as? HTTPURLResponse,
              let cachedResponseDateString = cachedResponse.value(forHTTPHeaderField: "Date"),
              let cachedResponseTimestamp: Date = dateFormatter.date(from: cachedResponseDateString)
        else {
            return true
        }

        let earlierDate: Date = cachedResponseTimestamp <= expirationTimestamp ? cachedResponseTimestamp : expirationTimestamp

        return earlierDate == cachedResponseTimestamp
    }
}
