import Foundation
import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights
@testable import BraintreeCore

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
    
    func testGetRecommendedPaymentMethods_callsEligiblePaymentsAPI() async {
        _ = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v2/payments/find-eligible-methods")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .payPalAPI)
        XCTAssertEqual(mockAPIClient.lastPOSTAdditionalHeaders?["PayPal-Client-Metadata-Id"], mockAPIClient.metadata.sessionID)
        
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
        let amount = purchaseUnits.first?["amount"] as! [String: String]
        XCTAssertEqual(amount["currency_code"], "USD")
    }
    
    func testGetRecommendedPaymentMethods_whenAPIError_throws() async {
        mockAPIClient.cannedResponseError = NSError(domain: "fake-error-domain", code: 123, userInfo: [NSLocalizedDescriptionKey:"fake-error-description"])
        
        do {
            _ = try await sut.getRecommendedPaymentMethods(request: request)
            XCTFail("Expected error to be thrown.")
        } catch let error as NSError {
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "fake-error-description")
            XCTAssertEqual(error.domain, "fake-error-domain")
            
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:failed")
        }
    }
    
    func testGetRecommendedPaymentMethods_whenAPISuccess_returnsResult() async {
        do {
            let mockEligiblePaymentMethodResponse = BTJSON(
                value: [
                    "eligible_methods": [
                        "venmo": [
                            "can_be_vaulted": true,
                            "eligible_in_paypal_network": true,
                            "recommended": true,
                            "recommended_priority": 1
                        ]
                    ]
                ]
            )
            mockAPIClient.cannedResponseBody = mockEligiblePaymentMethodResponse
            let result = try await sut.getRecommendedPaymentMethods(request: request)
            XCTAssertNotNil(result)
            XCTAssertTrue(result.isVenmoRecommended)
            XCTAssertFalse(result.isPayPalRecommended)
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:succeeded")
        } catch let error as NSError {
            XCTFail("An error was not expected.")
        }
    }
    
    func testGetRecommendedPaymentMethods_whenEligibleInPayPalNetworkTrue_returnsOnlyPayPalRecommended() async {
        do {
            let mockPayPalRecommendedResponse = BTJSON(
                value: [
                    "eligible_methods": [
                        "paypal": [
                            "can_be_vaulted": true,
                            "eligible_in_paypal_network": true,
                            "recommended": true,
                            "recommended_priority": 1
                        ]
                    ]
                ]
            )
            mockAPIClient.cannedResponseBody = mockPayPalRecommendedResponse
            let result = try await sut.getRecommendedPaymentMethods(request: request)
            XCTAssertTrue(result.isPayPalRecommended)
            XCTAssertFalse(result.isVenmoRecommended)
            XCTAssertTrue(result.isEligibleInPayPalNetwork)
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:succeeded")
        } catch {
            XCTFail("An error was not expected.")
        }
    }
    
    func testGetRecommendedPaymentMethods_whenEligibleInPayPalNetworkTrue_returnsOnlyVenmoRecommended() async {
        do {
            let mockVenmoRecommendedResponse = BTJSON(
                value: [
                    "eligible_methods": [
                        "venmo": [
                            "can_be_vaulted": true,
                            "eligible_in_paypal_network": true,
                            "recommended": true,
                            "recommended_priority": 1
                        ]
                    ]
                ]
            )
            mockAPIClient.cannedResponseBody = mockVenmoRecommendedResponse
            let result = try await sut.getRecommendedPaymentMethods(request: request)
            XCTAssertFalse(result.isPayPalRecommended)
            XCTAssertTrue(result.isVenmoRecommended)
            XCTAssertTrue(result.isEligibleInPayPalNetwork)
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:succeeded")
        } catch {
            XCTFail("An error was not expected.")
        }
    }
    
    func testGetRecommendedPaymentMethods_whenBothEligibleInPayPalNetworkFalse_returnsResult() async {
        do {
            let mockPayPalRecommendedResponse = BTJSON(
                value: [
                    "eligible_methods": [
                        "paypal": [
                            "can_be_vaulted": true,
                            "eligible_in_paypal_network": false,
                            "recommended": false,
                        ],
                        "venmo": [
                            "can_be_vaulted": true,
                            "eligible_in_paypal_network": false,
                            "recommended": false,
                        ]
                    ]
                ]
            )
            mockAPIClient.cannedResponseBody = mockPayPalRecommendedResponse
            let result = try await sut.getRecommendedPaymentMethods(request: request)
            XCTAssertFalse(result.isPayPalRecommended)
            XCTAssertFalse(result.isVenmoRecommended)
            XCTAssertFalse(result.isEligibleInPayPalNetwork)
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:succeeded")
        } catch {
            XCTFail("An error was not expected.")
        }
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
