import XCTest
@testable import BraintreeCore

final class BTClientMetadata_Tests: XCTestCase {

    func testSource_returnsExpectedString_forAllSources() {
        let metadata = BTClientMetadata()
        let sources = [
            BTClientMetadataSource.unknown: "unknown",
            BTClientMetadataSource.form: "form",
            BTClientMetadataSource.payPalApp: "paypal-app",
            BTClientMetadataSource.payPalBrowser: "paypal-browser",
            BTClientMetadataSource.venmoApp: "venmo-app"
        ]

        for (sourceNumber, _) in sources {
            metadata.source = BTClientMetadataSource(rawValue: sourceNumber.rawValue)!
            XCTAssertEqual(metadata.source.stringValue, sources[sourceNumber])
        }
    }

    func testIntegration_returnsExpectedString_forAllIntegrations() {
        XCTAssertEqual(BTClientMetadataIntegration.dropIn.stringValue, "dropin")
        XCTAssertEqual(BTClientMetadataIntegration.custom.stringValue, "custom")
    }

    func testSessionID_returns32CharacterUUIDString() {
        let metadata = BTClientMetadata()
        XCTAssertEqual(metadata.sessionID.count, 32)
    }

    func testSessionID_shouldBeDifferent_whenAnotherMetadataInstance() {
        let metdataOne = BTClientMetadata()
        let metdataTwo = BTClientMetadata()

        XCTAssertNotEqual(metdataOne.sessionID, metdataTwo.sessionID)
    }

    func testMetadata_init_containsExpectedDefaultValues() {
        let metadata = BTClientMetadata()
        XCTAssertEqual(metadata.integration, BTClientMetadataIntegration.custom)
        XCTAssertEqual(metadata.source, BTClientMetadataSource.unknown)
    }

    func testMetadata_init_containsExpectedValues_whenProvided() {
        let metadata = BTClientMetadata()
        metadata.integration = BTClientMetadataIntegration.dropIn
        metadata.source = BTClientMetadataSource.payPalApp

        XCTAssertEqual(metadata.integration, BTClientMetadataIntegration.dropIn)
        XCTAssertEqual(metadata.source, BTClientMetadataSource.payPalApp)
    }

    func testParameters_ReturnsTheMetadataMetaParametersForPosting() {
        let metadata = BTClientMetadata()
        let parameters = try? metadata.toDictionary() as? [String: String]
        let expectedParameters: [String: String] = [
            "integration": metadata.integration.stringValue,
            "source": metadata.source.stringValue,
            "sessionId": metadata.sessionID,
            "platform": "iOS",
            "version": BTCoreConstants.braintreeSDKVersion
        ]

        XCTAssertEqual(parameters, expectedParameters)
    }

}
