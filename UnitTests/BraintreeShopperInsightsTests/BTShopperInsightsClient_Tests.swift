import Foundation
import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class BTShopperInsightsClient_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var sut: BTShopperInsightsClient!
    
    let request = BTShopperInsightsRequest(
        email: "my-email",
        phone: Phone(
            countryCode: "1",
            nationalNumber: "1234567"
        )
    )
    
    override func setUp() {
        super.setUp()
        sut = BTShopperInsightsClient(apiClient: mockAPIClient)
    }
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isVenmoRecommended)
    }
    
    func testGetRecommendedPaymentMethods_whenBothAppsInstalled_returnsTrue() async {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://")!)
        fakeApplication.canOpenURLWhitelist.append(URL(string: "paypal://")!)
        sut.application = fakeApplication
        
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertTrue(result!.isPayPalRecommended)
        XCTAssertTrue(result!.isVenmoRecommended)
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
