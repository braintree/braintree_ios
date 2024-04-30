import XCTest
@testable import BraintreeCore

class BTURLCacheManager_Tests: XCTestCase {
    
    private var sut: BTURLCacheManager!
    private var mockCache: MockURLCache!

    override func setUp() {
        mockCache = MockURLCache()
        sut = BTURLCacheManager(cache: mockCache)
    }

    func testPutInCache_ifSuccessStatusCode_caches() {
        let urlRequest = URLRequest(url: URL(string: "www.fake-123.com")!)
        let response = HTTPURLResponse()
        
        sut.putInCache(request: urlRequest, response: response, data: Data(), statusCode: 249)
        
        XCTAssertNotNil(mockCache.cannedCache[urlRequest])
    }

    func testPutInCache_ifBadStatusCode_doesNotCache() {
        let urlRequest = URLRequest(url: URL(string: "www.fake.com")!)
        sut.putInCache(request: urlRequest, response: URLResponse(), data: Data(), statusCode: 301)
        
        XCTAssertEqual(mockCache.cannedCache, [:])
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
        let cachedResponse = CachedURLResponse(response: response, data: Data())
        mockCache.cannedCache = [urlRequest: cachedResponse]
        
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
        let cachedResponse = CachedURLResponse(response: response, data: Data())
        mockCache.cannedCache = [urlRequest: cachedResponse]
        
        XCTAssertNotNil(sut.getFromCache(request: urlRequest))
    }
}
