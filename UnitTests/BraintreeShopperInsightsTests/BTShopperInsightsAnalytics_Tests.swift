import XCTest
@testable import BraintreeShopperInsights

final class BTShopperInsightsAnalytics_Tests: XCTestCase {
    
    func test_recommendedPaymentAnalyticEvents_sendExpectedEventNames() {
        XCTAssertEqual(BTShopperInsightsAnalytics.buttonPresented, "shopper-insights:button-presented")
        XCTAssertEqual(BTShopperInsightsAnalytics.buttonSelected, "shopper-insights:button-selected")
        XCTAssertEqual(BTShopperInsightsAnalytics.recommendedPaymentsStarted, "shopper-insights:get-recommended-payments:started")
        XCTAssertEqual(BTShopperInsightsAnalytics.recommendedPaymentsSucceeded, "shopper-insights:get-recommended-payments:succeeded")
        XCTAssertEqual(BTShopperInsightsAnalytics.recommendedPaymentsFailed, "shopper-insights:get-recommended-payments:failed")
    }
}
