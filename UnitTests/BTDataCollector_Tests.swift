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
        dataCollector.collectCardFraudData()
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testFailsWithInvalidCollectorUrlAndCallsDelegateMethod() {
        let dataCollector = BTDataCollector(environment: .Sandbox)
        testDelegate = TestDelegateForBTDataCollector(didFailExpectation: expectationWithDescription("didFail"))
        dataCollector.delegate = testDelegate
        dataCollector.setCollectorUrl("fake url which should fail")
        dataCollector.collectCardFraudData()
        waitForExpectationsWithTimeout(5, handler: nil)
        
        XCTAssertEqual(testDelegate!.error!.domain, "URL validation failed") // Note: Kount provides NSError, so BTDataCollectorKountErrorDomain is not used.
        XCTAssertEqual(testDelegate!.error!.code, Int(DC_ERR_INVALID_URL))
        // Similarly, these keys are not set.
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
