import XCTest
@testable import BraintreeCard

final class BTCardAnalytics_Tests: XCTestCase {
    
    func test_tokenizeAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(BTCardAnalytics.cardTokenizeStarted, "card:tokenize:started")
        XCTAssertEqual(BTCardAnalytics.cardTokenizeFailed, "card:tokenize:failed")
        XCTAssertEqual(BTCardAnalytics.cardTokenizeSucceeded, "card:tokenize:succeeded")
    }
}
