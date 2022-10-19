import UIKit
import XCTest
@testable import BraintreeCoreSwift

final class BTAnalyticsMetadata_Tests: XCTestCase {

    func testMetadataContainsAllData() {
        let metadata = BTAnalyticsMetadata.metadata

        XCTAssertEqual(metadata["platform"] as? String, "iOS")
        XCTAssertNotNil(metadata["platformVersion"] as? String)
        XCTAssertEqual(metadata["sdkVersion"] as? String, BTCoreConstants.braintreeSDKVersion)
        XCTAssertNotNil(metadata["merchantAppId"] as? String)
        XCTAssertNotNil(metadata["merchantAppName"] as? String)
        XCTAssertNotNil(metadata["merchantAppVersion"] as? String)
        XCTAssertEqual(metadata["deviceManufacturer"] as? String, "Apple")
        XCTAssertNotNil(metadata["deviceModel"] as? String)
        XCTAssertNotNil(metadata["deviceAppGeneratedPersistentUuid"] as? String)
        XCTAssertNotNil(metadata["iosIdentifierForVendor"] as? String)
        XCTAssertNotNil(metadata["iosPackageManager"] as? String)
        XCTAssertNotNil(metadata["isSimulator"] as? Bool)
        XCTAssertNotNil(metadata["deviceScreenOrientation"] as? String)
    }

}
