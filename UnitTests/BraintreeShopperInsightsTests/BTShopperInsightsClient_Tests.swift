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
    
    // MARK: - getRecommendedPaymentMethods()
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isVenmoRecommended)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count-2], "shopper-insights:get-recommended-payments:started")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "shopper-insights:get-recommended-payments:succeeded")
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
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count-2], "shopper-insights:get-recommended-payments:started")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "shopper-insights:get-recommended-payments:succeeded")
    }
    
    func testGetRecommendedPaymentMethods_whenAppsNotInstalled_callsEligiblePaymentsAPI() async {
        _ = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v2/payments/find-eligible-methods")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .payPalAPI)
        
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        
        let customer = lastPostParameters["customer"] as! [String: Any]
        XCTAssertEqual((customer["country_code"] as! String), "US")
        XCTAssertEqual((customer["email"] as! String), "my-email")
        XCTAssertEqual((customer["phone"] as! [String: String])["country_code"], "1")
        XCTAssertEqual((customer["phone"] as! [String: String])["national_number"], "1234567")

        let preferences = lastPostParameters["preferences"] as! [String: Any]
        XCTAssertTrue(preferences["include_account_details"] as! Bool)
        let paymentSourceConstraint = preferences["payment_source_constraint"] as! [String: Any]
        XCTAssertEqual(paymentSourceConstraint["constraint_type"] as! String, "INCLUDE")
        XCTAssertEqual(paymentSourceConstraint["payment_sources"] as! [String], ["PAYPAL", "VENMO"])
        
        let purchaseUnits = lastPostParameters["purchase_units"] as! [[String: Any]]
        let payee = purchaseUnits.first?["payee"] as! [String: String]
        XCTAssertEqual(payee["merchant_id"], "TODO-merchant-id-type")
        let amount = purchaseUnits.first?["amount"] as! [String: String]
        XCTAssertEqual(amount["currency_code"], "USD")
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
