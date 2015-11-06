import XCTest

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
        let jsonString = dataCollector.collectCardFraudData()
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
        XCTAssert((dictionary["device_session_id"] as! String).characters.count >= 32)
        XCTAssertEqual(dictionary["fraud_merchant_id"] as? String, "600000") // BTDataCollectorSharedMerchantId
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testFailsWithInvalidCollectorUrlAndCallsDelegateMethod() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didFailExpectation: expectationWithDescription("didFail"))
        dataCollector.delegate = testDelegate
        dataCollector.setCollectorUrl("fake url which should fail")
        dataCollector.collectCardFraudData()
        waitForExpectationsWithTimeout(5, handler: nil)
        
        // Note: Kount provides NSError, so BTDataCollectorKountErrorDomain is not used.
        XCTAssertEqual(testDelegate!.error!.domain, "URL validation failed")
        XCTAssertEqual(testDelegate!.error!.code, Int(DC_ERR_INVALID_URL))
        // Similarly, userInfo is not set, so these keys are nil.
        //XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedDescriptionKey] as? String, "Failed to send data")
        //XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedFailureReasonErrorKey] as? String, "Invalid collector URL")
        XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedDescriptionKey] as? String, nil)
        XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedFailureReasonErrorKey] as? String, nil)
    }
    
    func testFailsWithInvalidMerchantIdAndCallsDelegateMethod() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didFailExpectation: expectationWithDescription("didFail"))
        dataCollector.delegate = testDelegate
        dataCollector.setFraudMerchantId("fake merchant id which should fail")
        dataCollector.collectCardFraudData()
        waitForExpectationsWithTimeout(5, handler: nil)
        
        XCTAssertEqual(testDelegate!.error!.domain, "Merchant ID validation failed")
        XCTAssertEqual(testDelegate!.error!.code, Int(DC_ERR_INVALID_MERCHANT))
        XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedDescriptionKey] as? String, nil)
        XCTAssertEqual(testDelegate!.error!.userInfo[NSLocalizedFailureReasonErrorKey] as? String, nil)
    }
    
    func testPayPalClientMetadataId() {
        let clientMetadataId = BTDataCollector.payPalClientMetadataId()
        // Ensure clientMetadataId is not nil and has a length of at least 12.
        // This is just a guess of a reasonable id length. In practice, the id
        // should have a length of 32.
        XCTAssert(clientMetadataId!.characters.count >= 12)
    }
    
    func testCollectPayPalClientMetadataId() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        let deviceData = dataCollector.collectPayPalClientMetadataId()
        let data = deviceData.dataUsingEncoding(NSUTF8StringEncoding)
        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
        // Ensure correlation_id (clientMetadataId) is not nil and has a length of at least 12.
        // This is just a guess of a reasonable id length. In practice, the id
        // typically has a length of 32.
        XCTAssert((dictionary["correlation_id"] as! String).characters.count >= 32)
    }
    
    /// Ensure that both Kount and PayPal data can be collected together
    func testCollectFraudData() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didStartExpectation: expectationWithDescription("didStart"), didCompleteExpectation: expectationWithDescription("didComplete"))
        dataCollector.delegate = testDelegate
        let jsonString = dataCollector.collectFraudData()
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
        XCTAssert((dictionary["device_session_id"] as! String).characters.count >= 32)
        XCTAssertEqual(dictionary["fraud_merchant_id"] as? String, "600000") // BTDataCollectorSharedMerchantId
        
        // Ensure correlation_id (clientMetadataId) is not nil and has a length of at least 12.
        // This is just a guess of a reasonable id length. In practice, the id
        // typically has a length of 32.
        XCTAssert((dictionary["correlation_id"] as! String).characters.count >= 32)
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
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
