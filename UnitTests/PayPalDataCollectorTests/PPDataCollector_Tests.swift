import XCTest
import PPRiskMagnes
@testable import PayPalDataCollector

class PPDataCollector_Tests: XCTestCase {

    func testDeviceData_containsCorrelationId() {
        let deviceData = PPDataCollector.collectPayPalDeviceData()
        guard let data = deviceData.data(using: .utf8) else { XCTFail(); return }

        let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String]
        XCTAssertNotNil(dictionary?["correlation_id"])
    }

    func testClientMetadata_isNotJSON() {
        let cmid = PPDataCollector.generateClientMetadataID(isSandbox: true)
        guard let cmidJSONData = cmid.data(using: .utf8) else { XCTFail(); return }

        XCTAssertEqual(PPDataCollector.mangnesEnvironment, MagnesSDK.Environment.SANDBOX)
        XCTAssertThrowsError(try JSONSerialization.jsonObject(with: cmidJSONData, options: .mutableContainers))
    }

    func testClientMetadataValue_whenUsingPairingID_isDifferentWhenSubsequentCallsDoNotSpecifyPairingID() {
        let pairingID = "random pairing id"
        XCTAssertEqual(pairingID, PPDataCollector.clientMetadataID(pairingID))
        XCTAssertNotEqual(pairingID, PPDataCollector.generateClientMetadataID(isSandbox: true))
        XCTAssertEqual(PPDataCollector.mangnesEnvironment, MagnesSDK.Environment.SANDBOX)
        XCTAssertNotEqual(pairingID, PPDataCollector.clientMetadataID(nil))
    }

    func testClientMetadataValue_isRegeneratedOnNonNullPairingID() {
        let cmid = PPDataCollector.generateClientMetadataID(isSandbox: false)
        XCTAssertEqual(PPDataCollector.mangnesEnvironment, MagnesSDK.Environment.LIVE)
        let cmid2 = PPDataCollector.clientMetadataID("some pairing id")
        XCTAssertNotEqual(cmid, cmid2)
    }
    
    func testClientMetadataID_noEnvironmentPassed_returnsLive() {
        let dataCollector = PPDataCollector.self
            
        XCTAssertEqual(dataCollector.clientMetadataID("a-pairing-id"), "a-pairing-id")
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.LIVE)
    }
    
    func testClientMetadataID_environmentPassed_returnsEnvironment() {
        let dataCollector = PPDataCollector.self
            
        XCTAssertEqual(dataCollector.clientMetadataID("a-pairing-id", isSandbox: true), "a-pairing-id")
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.SANDBOX)
    }
    
    func testCollectPayPalDeviceData_noEnvironmentPassed_returnsLive() {
        let dataCollector = PPDataCollector.self
        
        XCTAssertNotNil(dataCollector.collectPayPalDeviceData())
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.LIVE)
    }
    
    func testCollectPayPalDeviceData_environmentPassed_returnsEnvironment() {
        let dataCollector = PPDataCollector.self

        XCTAssertNotNil(dataCollector.collectPayPalDeviceData(isSandbox: false))
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.LIVE)
    }
    
    func testSandboxGenerateClientMetadataID_returnsEnvironmentSandbox() {
        let dataCollector = PPDataCollector.self

        XCTAssertNotNil(dataCollector.sandboxGenerateClientMetadataID())
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.SANDBOX)
    }
    
    func testGenerateClientMetadataID_returnsEnvironmentProduction() {
        let dataCollector = PPDataCollector.self

        XCTAssertNotNil(dataCollector.generateClientMetadataID())
        XCTAssertEqual(dataCollector.mangnesEnvironment, MagnesSDK.Environment.LIVE)

    }
}
