import XCTest
@testable import BraintreeCore

class ConfigurationCache_Tests: XCTestCase {
    
    private let sut = ConfigurationCache.shared
    private var fakeConfiguration: BTConfiguration!
    private let base64EndodedCat: NSString = "Y2F0"
    private let base64EncodedDog: NSString = "ZG9n"
    
    override func setUp() {
        sut.cacheInstance.removeAllObjects()
        fakeConfiguration = BTConfiguration(json: BTJSON(value: ["test": "value", "environment": "fake-env1"]))
    }

    func testPutInCache_cachesItemWithBase64EncodedKey() throws {
        try sut.putInCache(authorization: "dog", configuration: fakeConfiguration)
        
        XCTAssertEqual(sut.cacheInstance.object(forKey: base64EncodedDog), fakeConfiguration)
    }
    
    func testPutInCache_whenBase64EncodingFails_throwsError() {
        do {
            try sut.putInCache(authorization: "💇‍♀️", configuration: fakeConfiguration)
        } catch {
            XCTAssertEqual(error.localizedDescription, "Unable to base64 encode the authorization string.")
        }
    }
    
    func testGetFromCache_ifCachedItemExpired_returnsNil() throws {
        fakeConfiguration.time = Date().timeIntervalSince1970 - 301 // 5 minutes, and 1 second ago
        sut.cacheInstance.setObject(fakeConfiguration, forKey: base64EndodedCat)
        
        XCTAssertNil(try sut.getFromCache(authorization: "cat"))
    }
    
    func testGetFromCache_ifCachedItemValid_returnsItem() throws {
        sut.cacheInstance.setObject(fakeConfiguration, forKey: base64EndodedCat)

        let cachedItem = try sut.getFromCache(authorization: "cat")
        XCTAssertEqual(cachedItem, fakeConfiguration)
    }
}
