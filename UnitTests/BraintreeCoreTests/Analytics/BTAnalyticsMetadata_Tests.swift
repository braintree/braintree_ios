import UIKit
import XCTest
@testable import BraintreeCore

final class BTAnalyticsMetadata_Tests: XCTestCase {

    func testMetadata_ContainsValidData() {
        let metadata = BTAnalyticsMetadata.metadata

        XCTAssertEqual(metadata["platform"] as? String, "iOS")
        XCTAssertTrue((metadata["sdkVersion"] as! String).matches("^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
        XCTAssertEqual(metadata["merchantAppId"] as? String, "com.apple.dt.xctest.tool")
        XCTAssertEqual(metadata["merchantAppName"] as? String, "xctest")
        XCTAssertNotNil(metadata["merchantAppVersion"] as? String)
        XCTAssertNotNil(metadata["iosDeviceName"] as? String)
        XCTAssertTrue((metadata["iosSystemName"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(metadata["deviceManufacturer"] as? String, "Apple")
        XCTAssertTrue((metadata["deviceModel"] as! String).matches("iPhone\\d,\\d|i386|x86_64|arm64"))
        XCTAssertTrue((metadata["iosPackageManager"] as! String).matches("Carthage or Other|CocoaPods|Swift Package Manager"))
        XCTAssertEqual(metadata["isSimulator"] as? Bool, true)
    }
}
