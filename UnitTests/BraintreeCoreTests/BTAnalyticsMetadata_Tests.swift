import UIKit
import XCTest
@testable import BraintreeCore

final class BTAnalyticsMetadata_Tests: XCTestCase {

    func testMetadata_ContainsValidData() {
        let metadata = BTAnalyticsMetadata.metadata

        XCTAssertEqual(metadata["platform"] as? String, "iOS")
        XCTAssert((metadata["platformVersion"] as! String).matches("^\\d+\\.\\d+(\\.\\d+)?$"))
        XCTAssert((metadata["sdkVersion"] as! String).matches("^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
        XCTAssertNotNil(metadata["merchantAppId"] as? String)
        XCTAssertNotNil(metadata["merchantAppName"] as? String)
        XCTAssertNotNil(metadata["merchantAppVersion"] as? String)
        XCTAssertEqual(metadata["deviceManufacturer"] as? String, "Apple")
        XCTAssert((metadata["deviceModel"] as! String).matches("iPhone\\d,\\d|i386|x86_64|arm64"))
        XCTAssertNotNil(metadata["deviceAppGeneratedPersistentUuid"] as? String)
        XCTAssertNotNil(metadata["iosIdentifierForVendor"] as? String)
        XCTAssertNotNil(metadata["iosPackageManager"] as? String)
        XCTAssertEqual(metadata["isSimulator"] as? Bool, true)
        XCTAssertEqual(metadata["deviceScreenOrientation"] as? String, "Unknown")
    }
}
