import XCTest
import PayPalDataCollector

class BTDataCollector_Tests: XCTestCase {
    
    var testDelegate: TestDelegateForBTDataCollector?
    
    /// We check the delegate because it's the only exposed property of the dataCollector
    func testInitsWithNilDelegate() {
        let dataCollector = BTDataCollector(environment: BTDataCollectorEnvironment.Sandbox)
        XCTAssertNil(dataCollector.delegate)
    }
    
    func testSuccessfullyCollectsCardDataAndCallsDelegateMethods() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didStartExpectation: expectationWithDescription("didStart"), didCompleteExpectation: expectationWithDescription("didComplete"))
        dataCollector.delegate = testDelegate
        let stubKount = FakeDeviceCollectorSDK()
        dataCollector.kount = stubKount

        let jsonString = dataCollector.collectCardFraudData()

        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
        XCTAssert((dictionary["device_session_id"] as! String).characters.count >= 32)
        XCTAssertEqual(dictionary["fraud_merchant_id"] as? String, "600000") // BTDataCollectorSharedMerchantId
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    /// Ensure that both Kount and PayPal data can be collected together
    func testCollectFraudData() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didStartExpectation: expectationWithDescription("didStart"), didCompleteExpectation: expectationWithDescription("didComplete"))
        dataCollector.delegate = testDelegate
        let stubKount = FakeDeviceCollectorSDK()
        dataCollector.kount = stubKount
        BTDataCollector.setPayPalDataCollectorClass(FakePPDataCollector.self)
        
        let jsonString = dataCollector.collectFraudData()
        
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
        XCTAssert((dictionary["device_session_id"] as! String).characters.count >= 32)
        XCTAssertEqual(dictionary["fraud_merchant_id"] as? String, "600000") // BTDataCollectorSharedMerchantId
        
        // Ensure correlation_id (clientMetadataId) is not nil and has a length of at least 12.
        // This is just a guess of a reasonable id length. In practice, the id
        // typically has a length of 32.
        XCTAssertEqual(dictionary["correlation_id"] as? String, "fakeclientmetadataid")

        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testCollectCardFraudData_doesNotReturnCorrelationId() {
        let apiClient = clientThatReturnsConfiguration([
            "environment":"development",
            "kount": [
                "enabled": true,
                "kountMerchantId": "500000"
            ]
        ])

        let dataCollector = BTDataCollector(APIClient: apiClient)
        let expectation = expectationWithDescription("Returns fraud data")
        
        dataCollector.collectCardFraudData { (fraudData: String) in
            let json = BTJSON(data: fraudData.dataUsingEncoding(NSUTF8StringEncoding)!)
            XCTAssertNil(json["correlation_id"] as? String)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testOverrideMerchantId_usesMerchantProvidedId() {
        let apiClient = clientThatReturnsConfiguration([
            "environment":"development",
            "kount": [
                "enabled": true,
                "kountMerchantId": "500000"
            ]
        ])
        
        let dataCollector = BTDataCollector(APIClient: apiClient)
        dataCollector.setFraudMerchantId("500001")
        let expectation = expectationWithDescription("Returns fraud data")
        
        dataCollector.collectFraudData { (fraudData: String) in
            let json = BTJSON(data: fraudData.dataUsingEncoding(NSUTF8StringEncoding)!)
            XCTAssertEqual(json["fraud_merchant_id"].asString(), "500001")
            XCTAssert(json["device_session_id"].asString()?.characters.count >= 32)
            XCTAssert(json["correlation_id"].asString()?.characters.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testCollectFraudDataWithCompletionBlock_whenMerchantHasKountConfiguration_usesConfiguration() {
        let apiClient = clientThatReturnsConfiguration([
            "environment": "development",
            "kount": [
                "enabled": true,
                "kountMerchantId": "500000"
            ]
        ])
        let dataCollector = BTDataCollector(APIClient: apiClient)

        let expectation = expectationWithDescription("Returns fraud data")
        dataCollector.collectFraudData { fraudData in
            let json = BTJSON(data: fraudData.dataUsingEncoding(NSUTF8StringEncoding)!)
            XCTAssertEqual(json["fraud_merchant_id"].asString(), "500000")
            XCTAssert(json["device_session_id"].asString()!.characters.count >= 32)
            XCTAssert(json["correlation_id"].asString()!.characters.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCollectFraudDataWithCompletionBlock_whenMerchantHasKountConfiguration_setsMerchantIDOnKount() {
        let apiClient = clientThatReturnsConfiguration([
            "environment": "sandbox",
            "kount": [
                "enabled": true,
                "kountMerchantId": "500000"
            ]
        ])
        let dataCollector = BTDataCollector(APIClient: apiClient)
        let stubKount = FakeDeviceCollectorSDK()
        dataCollector.kount = stubKount

        let expectation = expectationWithDescription("Returns fraud data")
        dataCollector.collectFraudData { fraudData in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)

        XCTAssertEqual(500000, stubKount.merchantID)
        XCTAssertEqual(KEnvironment.Test, stubKount.environment)
    }

    func testCollectFraudData_doesNotCollectKountDataIfDisabledInConfiguration() {
        let apiClient = clientThatReturnsConfiguration([
            "environment":"development"
        ])
        
        let dataCollector = BTDataCollector(APIClient: apiClient)
        let expectation = expectationWithDescription("Returns fraud data")
        dataCollector.collectFraudData { fraudData in
            let json = BTJSON(data: fraudData.dataUsingEncoding(NSUTF8StringEncoding)!)
            XCTAssertNil(json["fraud_merchant_id"] as? String)
            XCTAssertNil(json["device_session_id"] as? String)
            XCTAssert(json["correlation_id"].asString()?.characters.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}

func clientThatReturnsConfiguration(configuration: [String:AnyObject]) -> BTAPIClient {
    let apiClient = BTAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)!
    let fakeHttp = BTFakeHTTP()!
    let cannedConfig = BTJSON(value: configuration)
    fakeHttp.cannedConfiguration = cannedConfig
    fakeHttp.cannedStatusCode = 200
    apiClient.configurationHTTP = fakeHttp
    
    return apiClient
}

class TestDelegateForBTDataCollector: NSObject, BTDataCollectorDelegate {
    
    var didStartExpectation: XCTestExpectation?
    var didCompleteExpectation: XCTestExpectation?
    
    var didFailExpectation: XCTestExpectation?
    var error: NSError?
    
    init(didStartExpectation: XCTestExpectation, didCompleteExpectation: XCTestExpectation) {
        self.didStartExpectation = didStartExpectation
        self.didCompleteExpectation = didCompleteExpectation
    }
    
    init(didFailExpectation: XCTestExpectation) {
        self.didFailExpectation = didFailExpectation
    }
    
    func dataCollectorDidStart(dataCollector: BTDataCollector) {
        didStartExpectation?.fulfill()
    }
    
    func dataCollectorDidComplete(dataCollector: BTDataCollector) {
        didCompleteExpectation?.fulfill()
    }
    
    func dataCollector(dataCollector: BTDataCollector, didFailWithError error: NSError) {
        self.error = error
        self.didFailExpectation?.fulfill()
    }
}

class FakeDeviceCollectorSDK: KDataCollector {
    
    var lastCollectSessionID: String?
    var forceError = false

    override func collectForSession(sessionID: String, completion completionBlock: ((String, Bool, NSError?) -> Void)?) {
        lastCollectSessionID = sessionID
        if forceError {
            completionBlock?("1981", false, NSError(domain: "Fake", code: 1981, userInfo: nil))
        } else {
            completionBlock?(sessionID, true, nil)
        }
    }
}

class FakePPDataCollector: PPDataCollector {
    
    static var didGetClientMetadataID = false

    override class func generateClientMetadataID() -> String {
        return generateClientMetadataID(nil)
    }

    override class func generateClientMetadataID(pairingID: String?) -> String {
        didGetClientMetadataID = true
        return "fakeclientmetadataid"
    }
}
