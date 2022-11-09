import XCTest
import BraintreeCore

class BTVersion_Tests: XCTestCase {
    func testVersion_returnsAVersion() {
        let regex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+", options: [])
        let matches = regex.matches(in: BTCoreConstants.braintreeSDKVersion, options: [], range: NSMakeRange(0, BTCoreConstants.braintreeSDKVersion.count))
        XCTAssertTrue(matches.count == 1)
    }
}
