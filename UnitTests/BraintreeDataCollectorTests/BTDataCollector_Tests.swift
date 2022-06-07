import XCTest
import BraintreeCore
import BraintreeTestShared
import PPRiskMagnes
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
        let expectation = self.expectation(description: "Returns fraud data")
        
        dataCollector.collectDeviceData(kountMerchantID: "500001") { deviceData, _ in
            if let deviceData = deviceData {
                let json = BTJSON(data: deviceData.data(using: .utf8)!)
                XCTAssertEqual((json["fraud_merchant_id"]).asString(), "500001")
                XCTAssert((json["device_session_id"]).asString()!.count >= 32)
                 XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
                expectation.fulfill()
            } else {
                XCTFail("We should return the expected data")
            }
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
        dataCollector.collectDeviceData { deviceData, _ in
            if let deviceData = deviceData {
                let json = BTJSON(data: deviceData.data(using: .utf8)!)
                XCTAssertEqual((json["fraud_merchant_id"]).asString(), "500000")
                XCTAssert((json["device_session_id"]).asString()!.count >= 32)
                 XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
                expectation.fulfill()
            } else {
                XCTFail("We should return the expected data")
            }
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
        dataCollector.collectDeviceData { _, _ in
            XCTAssertEqual(500000, stubKount.merchantID)
            XCTAssertEqual(KEnvironment.test, stubKount.environment)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCollectDeviceData_whenMerchantNotConfiguredForKount_doesNotCollectKountData() {
        let config: [String: Any] = [
            "environment": "development",
            "kount": [
                "kountMerchantId": nil
            ]
        ]
        
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)
        
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Returns fraud data")
        dataCollector.collectDeviceData { deviceData, _ in
            if let deviceData = deviceData {
                let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
                XCTAssertNil(json["fraud_merchant_id"].asString())
                XCTAssertNil(json["device_session_id"].asString())
                XCTAssert((json["correlation_id"] as AnyObject).asString()!.count > 0)
                expectation.fulfill()
            } else {
                XCTFail("We should return the expected data")
            }
        }

        waitForExpectations(timeout: 2)
    }

    func testDeviceData_containsCorrelationId() {
        let config: [String : Any] = [
            "environment":"sandbox"
        ]

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: config)

        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Returns fraud data")

        dataCollector.collectDeviceData { deviceData, _ in
            if let deviceData = deviceData {
                let json = BTJSON(data: deviceData.data(using: String.Encoding.utf8)!)
                XCTAssertNotNil(json["correlation_id"])
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2)
    }

    func testClientMetadata_isNotJSON() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)
        let sessionID = dataCollector.generateSessionID()
        
        guard let clientMetadataIDJSONData = sessionID.data(using: .utf8) else {
            XCTFail("Data should be returned as expected")
            return
        }

        XCTAssertThrowsError(try JSONSerialization.jsonObject(with: clientMetadataIDJSONData, options: .mutableContainers))
    }

    func testClientMetadataValue_whenUsingPairingID_isDifferentWhenSubsequentCallsDoNotSpecifyPairingID() {
        let config: [String : Any] = [
            "environment":"sandbox"
        ]
        
        let configuration = BTConfiguration(json: BTJSON(value: config))
        let pairingID = "random pairing id"
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        XCTAssertEqual(pairingID, dataCollector.clientMetadataID(pairingID))
        XCTAssertNotEqual(pairingID, dataCollector.generateClientMetadataID(with: configuration))
        XCTAssertNotEqual(pairingID, dataCollector.clientMetadataID(nil))
    }

    func testClientMetadataValue_isRegeneratedOnNonNullPairingID() {
        let config: [String : Any] = [
            "environment":"sandbox"
        ]
        
        let configuration = BTConfiguration(json: BTJSON(value: config))
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        let clientMetaDataID = dataCollector.generateClientMetadataID(with: configuration)
        let clientMetaDataID2 = dataCollector.clientMetadataID("some pairing id")
        XCTAssertNotEqual(clientMetaDataID, clientMetaDataID2)
    }

    func testClientMetadataID_sandboxPassedToConfig_returnsSandbox() {
        let config: [String : Any] = [
            "environment":"sandbox"
        ]
        
        let configuration = BTConfiguration(json: BTJSON(value: config))
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        XCTAssertNotNil(dataCollector.generateClientMetadataID(with: configuration))
        XCTAssertEqual(dataCollector.getMagnesEnvironment(from: dataCollector.config), MagnesSDK.Environment.SANDBOX)
    }
    
    func testClientMetadataID_productionPassedToConfig_returnsProduction() {
        let config: [String : Any] = [
            "environment":"production"
        ]
        
        let configuration = BTConfiguration(json: BTJSON(value: config))
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        XCTAssertNotNil(dataCollector.generateClientMetadataID(with: configuration))
        XCTAssertEqual(dataCollector.getMagnesEnvironment(from: dataCollector.config), MagnesSDK.Environment.LIVE)
    }

    func testClientMetadataID_invalidValuePassedToConfig_returnsDefaultLive() {
        let config: [String : Any] = [
            "environment":"fake-env"
        ]
        
        let configuration = BTConfiguration(json: BTJSON(value: config))
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let dataCollector = BTDataCollector(apiClient: mockAPIClient)

        XCTAssertNotNil(dataCollector.generateClientMetadataID(with: configuration))
        XCTAssertEqual(dataCollector.getMagnesEnvironment(from: dataCollector.config), MagnesSDK.Environment.LIVE)
    }
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
