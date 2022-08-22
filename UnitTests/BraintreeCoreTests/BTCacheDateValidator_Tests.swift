import XCTest
@testable import BraintreeCoreSwift

class BTCacheDateValidator_Tests: XCTestCase {
    func testTimeToLiveMinutes_defaultsTo5() {
        let cacheDateValidator = BTCacheDateValidator()
        XCTAssertEqual(5, cacheDateValidator.timeToLiveMinutes)
    }
}
