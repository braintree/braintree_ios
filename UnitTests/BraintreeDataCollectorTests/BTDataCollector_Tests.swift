import XCTest
import BraintreeCore
import PPRiskMagnes
@testable import BraintreeTestShared
@testable import BraintreeDataCollector

class BTDataCollector_Tests: XCTestCase {

    func testCollectDeviceData_collectsAllData() {
        let config: [String: Any] = ["environment": "development"]
        
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
    
    func testCollectDeviceData_fetchConfigurationReturnsError_returnError() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let mockDataCollector = MockBTDataCollector(apiClient: mockAPIClient)

        mockDataCollector.cannedDataCollectorError = NSError(domain: "FakeConfigError", code: 1, userInfo: [NSLocalizedDescriptionKey:"Fake description"])

        let expectation = self.expectation(description: "Returns error")
        mockDataCollector.collectDeviceData { _, error in
            if let error = error as NSError? {
                XCTAssertEqual(error.domain, "FakeConfigError")
                XCTAssertEqual(error.code, 1)
                XCTAssertEqual(error.localizedDescription, "Fake description")
                expectation.fulfill()
            } else {
                XCTFail("We Should have received an error")
            }
        }

        waitForExpectations(timeout: 2)
    }
    
    func testCollectDeviceData_invalidJSON_returnError() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let mockDataCollector = MockBTDataCollector(apiClient: mockAPIClient)
        
        mockDataCollector.cannedDataCollectorError = BTDataCollectorError.jsonSerializationFailure

        let expectation = self.expectation(description: "Returns error")
        mockDataCollector.collectDeviceData { _, error in
            if let error = error as NSError? {
                XCTAssertEqual(error.domain, BTDataCollectorError.errorDomain)
                XCTAssertEqual(error.code, BTDataCollectorError.jsonSerializationFailure.errorCode)
                XCTAssertEqual(error.localizedDescription, BTDataCollectorError.jsonSerializationFailure.localizedDescription)
                expectation.fulfill()
            } else {
                XCTFail("We Should have received an error")
            }
        }

        waitForExpectations(timeout: 2)
    }
    
    func testCollectDeviceData_encodingError_returnError() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let mockDataCollector = MockBTDataCollector(apiClient: mockAPIClient)
        
        mockDataCollector.cannedDataCollectorError = BTDataCollectorError.encodingFailure

        let expectation = self.expectation(description: "Returns error")
        mockDataCollector.collectDeviceData { _, error in
            if let error = error as NSError? {
                XCTAssertEqual(error.domain, BTDataCollectorError.errorDomain)
                XCTAssertEqual(error.code, BTDataCollectorError.encodingFailure.errorCode)
                XCTAssertEqual(error.localizedDescription, BTDataCollectorError.encodingFailure.localizedDescription)
                expectation.fulfill()
            } else {
                XCTFail("We Should have received an error")
            }
        }

        waitForExpectations(timeout: 2)
    }
}
