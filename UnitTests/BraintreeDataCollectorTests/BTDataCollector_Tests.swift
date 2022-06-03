import XCTest
import BraintreeCore
import BraintreeTestShared
@testable import BraintreeDataCollector
@testable import BraintreeKountDataCollector

class BTDataCollector_Tests: XCTestCase {

    func testSetFraudMerchantID_overridesMerchantID() {
        let config: [String : Any] = [
            "environment":"development",
            "kount": [
                "kountMerchantId": "500000"
            ]
        ]

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)

        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
        dataCollector.setFraudMerchantID("500001")
        let expectation = self.expectation(description: "Returns fraud data")
        
        dataCollector.collectDeviceData { deviceData in
            let json = BTJSON(data: deviceData.data(using: .utf8)!)
            XCTAssertEqual((json["fraud_merchant_id"]).asString(), "500001")
            XCTAssert((json["device_session_id"]).asString()!.count >= 32)
            // TODO: update this when we add PayPalDataCollector to BraintreeDataCollector
            // XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }

    func testCollectDeviceData_whenMerchantConfiguredForKount_collectsAllData() {
        let config: [String : Any] = [
            "environment": "development",
            "kount": [
                "kountMerchantId": "500000"
            ]
        ]
        
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)

        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { deviceData in
            let json = BTJSON(data: deviceData.data(using: .utf8)!)
            XCTAssertEqual((json["fraud_merchant_id"]).asString(), "500000")
            XCTAssert((json["device_session_id"]).asString()!.count >= 32)
            // TODO: update this when we add PayPalDataCollector to BraintreeDataCollector
            // XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }

    func testCollectDeviceData_whenMerchantConfiguredForKount_setsMerchantIDOnKount() {
        let config: [String : Any] = [
            "environment": "sandbox",
            "kount": [
                "kountMerchantId": "500000"
            ]
        ]

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)

        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
        let stubKount = FakeDeviceCollectorSDK()
        dataCollector.kount = stubKount

        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(500000, stubKount.merchantID)
        XCTAssertEqual(KEnvironment.test, stubKount.environment)
    }

    // TODO: update this when we add PayPalDataCollector to BraintreeDataCollector
//    func testCollectDeviceData_whenMerchantNotConfiguredForKount_doesNotCollectKountData() {
//        let config = [
//            "environment": "development",
//            "kount": [
//                "kountMerchantId": nil
//            ]
//        ] as [String : Any]
//
//        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
//        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)
//
//        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
//        let expectation = self.expectation(description: "Returns fraud data")
//        dataCollector.collectDeviceData { deviceData in
//            let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
//            XCTAssertNil(json["fraud_merchant_id"].asString())
//            XCTAssertNil(json["device_session_id"].asString())
//            // TODO: update this when we add PayPalDataCollector to BraintreeDataCollector
//            XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 2, handler: nil)
//    }
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
