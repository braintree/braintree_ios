import UIKit
import XCTest
@testable import BraintreeCore

final class BTAnalyticsMetadata_Tests: XCTestCase {

    func testMetadata_ContainsValidData() {
        let metadata = BTAnalyticsMetadata.metadata

        XCTAssertEqual(metadata["platform"] as? String, "iOS")
        assertRegexMatch(metadata["platformVersion"] as? String, "^\\d+\\.\\d+(\\.\\d+)?$")
        assertRegexMatch(metadata["sdkVersion"] as? String, "^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$")
        XCTAssertNotNil(metadata["merchantAppId"] as? String) //OCMocked
        XCTAssertNotNil(metadata["merchantAppName"] as? String) // OCMocked
        XCTAssertNotNil(metadata["merchantAppVersion"] as? String) // OCMocked, could be regex
        XCTAssertEqual(metadata["deviceManufacturer"] as? String, "Apple")
        assertRegexMatch(metadata["deviceModel"] as? String, "iPhone\\d,\\d|i386|x86_64|arm64")
        XCTAssertNotNil(metadata["deviceAppGeneratedPersistentUuid"] as? String) // Empty String because there's no BTKeychain "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"
        XCTAssertNotNil(metadata["iosIdentifierForVendor"] as? String) // OCMock
        XCTAssertNotNil(metadata["iosPackageManager"] as? String)
        XCTAssertEqual(metadata["isSimulator"] as? Bool, true)
        XCTAssertEqual(metadata["deviceScreenOrientation"] as? String, "Unknown")
    }

    func assertRegexMatch(
        _ string: String?,
        _ pattern: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let string else {
            XCTFail("Regex input is nil", file: file, line: line)
            return
        }
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            XCTFail("\(pattern) is invalid", file: file, line: line)
            return
        }
        
        if regex.matches(in: string, range: NSMakeRange(0, string.count)).count <= 0 {
            XCTFail("input \"\(string)\" does not match pattern \"\(pattern)\"", file: file, line: line)
        }
    }
}
