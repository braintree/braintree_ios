import XCTest
import BraintreeDataCollector
import BraintreeTestShared

class BTDataCollector_Tests: XCTestCase {

    func testSetFraudMerchantID_overridesMerchantID() {
        let config = [
            "environment":"development",
            "kount": [
                "kountMerchantId": "500000"
            ]
        ] as [String : Any]
        
        let apiClient = clientThatReturnsConfiguration(config as [String : AnyObject])
        
        let dataCollector = BTDataCollector(apiClient: apiClient)
        dataCollector.setFraudMerchantID("500001")
        let expectation = self.expectation(description: "Returns fraud data")
        
        dataCollector.collectDeviceData { (deviceData: String) in
            let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
            XCTAssertEqual((json["fraud_merchant_id"] as AnyObject).asString(), "500001")
            XCTAssert((json["device_session_id"] as AnyObject).asString()!.count >= 32)
            XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCollectDeviceData_whenMerchantConfiguredForKount_collectsAllData() {
        let config = [
            "environment": "development" as AnyObject,
            "kount": [
                "kountMerchantId": "500000"
            ]
        ] as [String : Any]
        let apiClient = clientThatReturnsConfiguration(config as [String : AnyObject])
        let dataCollector = BTDataCollector(apiClient: apiClient)

        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { deviceData in
            let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
            XCTAssertEqual((json["fraud_merchant_id"] as AnyObject).asString(), "500000")
            XCTAssert((json["device_session_id"] as AnyObject).asString()!.count >= 32)
            XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCollectDeviceData_whenMerchantConfiguredForKount_setsMerchantIDOnKount() {
        let config = [
            "environment": "sandbox",
            "kount": [
                "kountMerchantId": "500000"
            ]
        ] as [String : Any]
        let apiClient = clientThatReturnsConfiguration(config as [String : AnyObject])
        let dataCollector = BTDataCollector(apiClient: apiClient)
        let stubKount = FakeDeviceCollectorSDK()
        dataCollector.kount = stubKount

        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(500000, stubKount.merchantID)
        XCTAssertEqual(KEnvironment.test, stubKount.environment)
    }

    func testCollectDeviceData_whenMerchantNotConfiguredForKount_doesNotCollectKountData() {
        let config = [
            "environment": "development",
            "kount": [
                "kountMerchantId": nil
            ]
        ] as [String : Any]
        let apiClient = clientThatReturnsConfiguration(config as [String : AnyObject])
        
        let dataCollector = BTDataCollector(apiClient: apiClient)
        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { deviceData in
            let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
            XCTAssertNil(json["fraud_merchant_id"] as? String)
            XCTAssertNil(json["device_session_id"] as? String)
            XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}

func clientThatReturnsConfiguration(_ configuration: [String:AnyObject]) -> BTAPIClient {
    let apiClient = BTAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)!
    let fakeHttp = FakeHTTP.fakeHTTP()
    let cannedConfig = BTJSON(value: configuration)
    fakeHttp.cannedConfiguration = cannedConfig
    fakeHttp.cannedStatusCode = 200
    apiClient.configurationHTTP = fakeHttp
    
    return apiClient
}

class FakeDeviceCollectorSDK: KDataCollector {
    
    var lastCollectSessionID: String?
    var forceError = false

    override func collect(forSession sessionID: String, completion completionBlock: ((String, Bool, Error?) -> Void)? = nil) {
        lastCollectSessionID = sessionID
        if forceError {
            completionBlock?("1981", false, NSError(domain: "Fake", code: 1981, userInfo: nil))
        } else {
            completionBlock?(sessionID, true, nil)
        }
    }
}
