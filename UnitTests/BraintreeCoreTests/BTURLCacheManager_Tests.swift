import XCTest
@testable import BraintreeCore

class ConfigurationCache_Tests: XCTestCase {
    
    private let sut = ConfigurationCache.shared
    private var fakeConfiguration: BTConfiguration!
    private let base64EndodedCat = "Y2F0"
    private let base64EncodedDog = "ZG9n"
    
    override func setUp() {
        sut.cachedConfigStorage = [:]
        fakeConfiguration = BTConfiguration(json: BTJSON(value: ["test": "value", "environment": "fake-env1"]))
    }

    func testPutInCache_cachesItemWithBase64EncodedKey() throws {
        try sut.putInCache(authorization: "dog", configuration: fakeConfiguration)
        
        XCTAssertEqual(sut.cachedConfigStorage[base64EncodedDog], fakeConfiguration)
    }
    
    func testGetFromCache_ifCachedItemExpired_returnsNil() throws {
        fakeConfiguration.time = Date().timeIntervalSince1970 - (60 * 6) // 6 minutes ago
        sut.cachedConfigStorage[base64EndodedCat] = fakeConfiguration
        
        XCTAssertNil(try sut.getFromCache(authorization: "cat"))
    }
    
    func testGetFromCache_ifCachedItemValid_returnsItem() throws {
        sut.cachedConfigStorage[base64EndodedCat] = fakeConfiguration
        
        let cachedItem = try sut.getFromCache(authorization: "cat")
        XCTAssertEqual(cachedItem, fakeConfiguration)
    }
}
