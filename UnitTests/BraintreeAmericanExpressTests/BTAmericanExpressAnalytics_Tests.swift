import XCTest
@testable import BraintreeAmericanExpress

final class BTAmericanExpress_Tests: XCTestCase {
    
    func test_getRewardsBalanceAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTAmericanExpressAnalytics.started, "amex:rewards-balance:started")
        XCTAssertEqual(BTAmericanExpressAnalytics.failed, "amex:rewards-balance:failed")
        XCTAssertEqual(BTAmericanExpressAnalytics.succeeded, "amex:rewards-balance:succeeded")
    }
}
