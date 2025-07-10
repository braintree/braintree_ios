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
    
    func test_createCustomerSessionAnalyticEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTShopperInsightsAnalytics.createCustomerSessionStarted, "shopper-insights:create-customer-session:started")
        XCTAssertEqual(BTShopperInsightsAnalytics.createCustomerSessionSucceeded, "shopper-insights:create-customer-session:succeeded")
        XCTAssertEqual(BTShopperInsightsAnalytics.createCustomerSessionFailed, "shopper-insights:create-customer-session:failed")
    }
    
    func test_updateCustomerSessionAnalyticEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTShopperInsightsAnalytics.updateCustomerSessionStarted, "shopper-insights:update-customer-session:started")
        XCTAssertEqual(BTShopperInsightsAnalytics.updateCustomerSessionSucceeded, "shopper-insights:update-customer-session:succeeded")
        XCTAssertEqual(BTShopperInsightsAnalytics.updateCustomerSessionFailed, "shopper-insights:update-customer-session:failed")
    }
}
