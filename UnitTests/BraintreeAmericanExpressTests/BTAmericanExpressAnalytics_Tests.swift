import XCTest
@testable import BraintreeAmericanExpress

final class BTAmericanExpress_Tests: XCTestCase {
    
    func test_getRewardsBalanceAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTAmericanExpressAnalytics.rewardsBalanceStarted, "amex:rewards-balance:started")
        XCTAssertEqual(BTAmericanExpressAnalytics.rewardsBalanceFailed, "amex:rewards-balance:failed")
        XCTAssertEqual(BTAmericanExpressAnalytics.rewardsBalanceSucceeded, "amex:rewards-balance:succeeded")
    }
}
