import Foundation
@testable import BraintreeCore

class MockURLCache: URLCacheable {
    
    var cannedCache: [URLRequest: CachedURLResponse] = [:]
    
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        cannedCache[request] = cachedResponse
    }
    
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return cannedCache[request]
    }
    
    func removeAllCachedResponses() {
        cannedCache = [:]
    }
}
