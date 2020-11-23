import XCTest
@testable import PayPalDataCollector

class PPDataCollector_Tests: XCTestCase {

    func testDeviceData_containsCorrelationId() {
        let deviceData = PPDataCollector.collectPayPalDeviceData()
        guard let data = deviceData.data(using: .utf8) else { XCTFail(); return }

        let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : String]
        XCTAssertNotNil(dictionary?["correlation_id"])
    }

    func testClientMetadata_isNotJSON() {
        let cmid = PPDataCollector.generateClientMetadataID()
        guard let cmidJSONData = cmid.data(using: .utf8) else { XCTFail(); return }

        XCTAssertThrowsError(try JSONSerialization.jsonObject(with: cmidJSONData, options: .mutableContainers))
    }

    func testClientMetadataValue_whenUsingPairingID_isDifferentWhenSubsequentCallsDoNotSpecifyPairingID() {
        let pairingID = "random pairing id"
        XCTAssertEqual(pairingID, PPDataCollector.clientMetadataID(pairingID))
        XCTAssertNotEqual(pairingID, PPDataCollector.generateClientMetadataID())
        XCTAssertNotEqual(pairingID, PPDataCollector.clientMetadataID(nil))
    }

    func testClientMetadataValue_isRegeneratedOnNonNullPairingID() {
        let cmid = PPDataCollector.generateClientMetadataID()
        let cmid2 = PPDataCollector.clientMetadataID("some pairing id")
        XCTAssertNotEqual(cmid, cmid2)
    }
}
