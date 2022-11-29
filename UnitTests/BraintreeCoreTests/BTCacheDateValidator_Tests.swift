import XCTest
@testable import BraintreeCore

class BTCacheDateValidator_Tests: XCTestCase {
    func testTimeToLiveMinutes_defaultsTo5() {
        let cacheDateValidator = BTCacheDateValidator()
        XCTAssertEqual(5, cacheDateValidator.timeToLiveMinutes)
    }
}
