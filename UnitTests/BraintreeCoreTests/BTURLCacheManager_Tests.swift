import XCTest
@testable import BraintreeCore

class BTURLCacheManager_Tests: XCTestCase {
    
    private var sut = BTURLCacheManager()

    override func setUp() {
        sut.cacheInstance.removeAllCachedResponses()
    }

    // WARNING: - These tests are expected to fail, after reading this SO post -     // https://stackoverflow.com/questions/52938033/urlresponse-is-not-retrieved-after-storing-in-cache-using-storecachedresponse
    // I learned URLCache is highly asynchronous, which is why these tests are failing. Adding a DispatchQueue.main.async() with delay 0.1 seconds causes these tests to pass, which I think was a red herring for our original fix added in braintree_ios PR #807
    
    func testPutInCache_ifSuccessStatusCode_caches() {
        let urlRequest = URLRequest(url: URL(string: "www.fake-123.com")!)
        let response = HTTPURLResponse()
        
        sut.putInCache(request: urlRequest, response: response, data: Data(), statusCode: 249)
        
        XCTAssertNotNil(sut.cacheInstance.cachedResponse(for: urlRequest))
    }

    func testPutInCache_ifBadStatusCode_doesNotCache() {
        let goodURLRequest = URLRequest(url: URL(string: "www.fake.com")!)
        sut.putInCache(request: goodURLRequest, response: URLResponse(), data: Data(), statusCode: 201)
        
        let badURLRequest = URLRequest(url: URL(string: "www.fake.com")!)
        sut.putInCache(request: badURLRequest, response: URLResponse(), data: Data(), statusCode: 301)
        
        XCTAssertNotNil(sut.cacheInstance.cachedResponse(for: goodURLRequest))
        XCTAssertNil(sut.cacheInstance.cachedResponse(for: badURLRequest))
    }
    
    func testGetFromCache_ifCachedItemInvalid_returnsNil() {
        // Setup - add expired item to cache
        let urlRequest = URLRequest(url: URL(string: "www.fake-request.com")!)
        let response = HTTPURLResponse(
            url: URL(string: "www.fake-request.com")!,
            statusCode: 201,
            httpVersion: "",
            headerFields: ["Date": "Mon, 10 Apr 2024, 10:00:00 PDT"]
        )!
        let responseToCache = CachedURLResponse(response: response, data: Data())
        sut.cacheInstance.storeCachedResponse(responseToCache, for: urlRequest)
        
        XCTAssertNil(sut.getFromCache(request: urlRequest))
    }
    
    func testGetFromCache_ifCachedItemValid_returnsItem() {
        // Setup - add current item to cache
        let urlRequest = URLRequest(url: URL(string: "www.fake-request.com")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH:mm:ss zzz"
        let dateNow = formatter.string(from: Date())
        
        let response = HTTPURLResponse(
            url: URL(string: "www.fake-request.com")!,
            statusCode: 201,
            httpVersion: "",
            headerFields: ["Date": dateNow]
        )!
        let responseToCache = CachedURLResponse(response: response, data: Data())
        sut.cacheInstance.storeCachedResponse(responseToCache, for: urlRequest)
        
        XCTAssertNotNil(sut.getFromCache(request: urlRequest))
    }
}
