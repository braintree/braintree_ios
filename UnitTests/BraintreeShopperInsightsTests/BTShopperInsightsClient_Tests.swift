import Foundation
import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class BTShopperInsightsClient_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var sut: BTShopperInsightsClient!
    
    override func setUp() {
        super.setUp()
        sut = BTShopperInsightsClient(apiClient: mockAPIClient)
    }
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let request = BTShopperInsightsRequest(
            email: "my-email",
            phone: Phone(
                countryCode: "1",
                nationalNumber: "1234567"
            )
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isVenmoRecommended)
    }
    
    // MARK: - Analytics
    
    func testSendPayPalPresentedEvent_sendsAnalytic() {
        sut.sendPayPalPresentedEvent()
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:paypal-presented")
    }
    
    func testSendPayPalSelectedEvent_sendsAnalytic() {
        sut.sendPayPalSelectedEvent()
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:paypal-selected")
    }
    
    func testSendVenmoPresentedEvent_sendsAnalytic() {
        sut.sendVenmoPresentedEvent()
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:venmo-presented")
    }
    
    func testSendVenmoSelectedEvent_sendsAnalytic() {
        sut.sendVenmoSelectedEvent()
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:venmo-selected")
    }
}
