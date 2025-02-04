import Foundation
import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights
@testable import BraintreeCore

class BTShopperInsightsClient_Tests: XCTestCase {
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    var mockAPIClient: MockAPIClient!
    var sut: BTShopperInsightsClient!
    
    let request = BTShopperInsightsRequest(
        email: "my-email",
        phone: Phone(
            countryCode: "1",
            nationalNumber: "1234567"
        )
    )
    
    let sampleExperiment =
            """
            [
              {
                "experimentName" : "payment ready conversion",
                "experimentID" : "a1b2c3" ,
                "treatmentName" : "control group 1",
              }
            ]
            """

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTShopperInsightsClient(apiClient: mockAPIClient!, shopperSessionID: "fake-shopper-session-id")
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
            XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
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
            XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
        } catch let error as NSError {
            XCTFail("An error was not expected.")
        }
    }
    
    func testGetRecommendedPaymentMethods_whenEligibleInPayPalNetworkTrueANDMerchantExperimentSet_returnsOnlyPayPalRecommended() async {
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
            let result = try await sut.getRecommendedPaymentMethods(request: request, experiment: sampleExperiment)
            XCTAssertTrue(result.isPayPalRecommended)
            XCTAssertFalse(result.isVenmoRecommended)
            XCTAssertTrue(result.isEligibleInPayPalNetwork)
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, "shopper-insights:get-recommended-payments:succeeded")
            XCTAssertEqual(mockAPIClient.postedMerchantExperiment, sampleExperiment)
            XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
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
            XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
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
            XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
        } catch {
            XCTFail("An error was not expected.")
        }
    }

    func testGetRecommendedPaymentMethods_withTokenizationKey_returnsError() async {
        let apiClient = BTAPIClient(authorization: "sandbox_merchant_1234567890abc")!
        let shopperInsightsClient = BTShopperInsightsClient(apiClient: apiClient)

        do {
            let result = try await shopperInsightsClient.getRecommendedPaymentMethods(request: request)
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.code, 1)
            XCTAssertEqual(error.localizedDescription, "Invalid authorization. This feature can only be used with a client token.")
        }
    }

    // MARK: - Analytics
    
    func testSendPayPalPresentedEvent_whenExperimentTypeIsControl_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .control,
            pageType: .about
        )
        sut.sendPresentedEvent(for: .payPal, presentmentDetails: presentmentDetails)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-presented")
        XCTAssertEqual(mockAPIClient.postedButtonOrder, "1")
        XCTAssertEqual(mockAPIClient.postedButtonType, "PayPal")
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "control" }
            ]
        """)
        XCTAssertEqual(mockAPIClient.postedPageType, "about")
    }

    func testSendPayPalPresentedEvent_whenExperimentTypeIsTest_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .test,
            pageType: .about
        )
        sut.sendPresentedEvent(for: .payPal, presentmentDetails: presentmentDetails)
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "test" }
            ]
        """)
    }

    func testSendPayPalSelectedEvent_sendsAnalytic() {
        sut.sendSelectedEvent(for: .payPal)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-selected")
        XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
        XCTAssertEqual(mockAPIClient.postedButtonType, "PayPal")
    }

    func testSendVenmoPresentedEvent_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .control,
            pageType: .about
        )
        sut.sendPresentedEvent(for: .venmo, presentmentDetails: presentmentDetails)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-presented")
        XCTAssertEqual(mockAPIClient.postedButtonOrder, "1")
        XCTAssertEqual(mockAPIClient.postedButtonType, "Venmo")
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "control" }
            ]
        """)
        XCTAssertEqual(mockAPIClient.postedPageType, "about")
    }

    func testSendVenmoPresentedEvent_whenExperimentTypeIsTest_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .test,
            pageType: .about
        )
        sut.sendPresentedEvent(for: .venmo, presentmentDetails: presentmentDetails)
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "test" }
            ]
        """)
    }
    
    func testSendVenmoSelectedEvent_sendsAnalytic() {
        sut.sendSelectedEvent(for: .venmo)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-selected")
        XCTAssertEqual(mockAPIClient.postedButtonType, "Venmo")
        XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
    }

    // MARK: - App Installed Methods

    func testIsPayPalAppInstalled_whenPayPalAppNotInstalled_returnsFalse() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false

        XCTAssertFalse(sut.isPayPalAppInstalled())
    }

    func testIsPayPalAppInstalled_whenPayPalAppIsInstalled_returnsTrue() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = true
        fakeApplication.canOpenURLWhitelist.append(URL(string: "paypal-app-switch-checkout://x-callback-url/path")!)
        sut.application = fakeApplication

        XCTAssertTrue(sut.isPayPalAppInstalled())
    }

    func testIsVenmoAppInstalled_whenVenmoAppNotInstalled_returnsFalse() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false

        XCTAssertFalse(sut.isVenmoAppInstalled())
    }

    func testIsVenmoAppInstalled_whenVenmoAppIsInstalled_returnsTrue() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = true
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        sut.application = fakeApplication

        XCTAssertTrue(sut.isVenmoAppInstalled())
    }
}
