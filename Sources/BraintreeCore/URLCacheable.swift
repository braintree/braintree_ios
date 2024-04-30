import Foundation

/// Protocol to abstract URLCache, for testing
protocol URLCacheable {
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    func removeAllCachedResponses()
}

extension URLCache: URLCacheable { }
