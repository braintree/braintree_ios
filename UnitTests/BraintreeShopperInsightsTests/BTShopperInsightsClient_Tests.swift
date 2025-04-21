import Foundation
import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights
@testable import BraintreeCore

/// That's why we defined the interface — to make mocking easier. We’re using conformance instead of inheritance.
class MockFind: BTFindEligibleMethodsServiceable {
    
    let apiClient: BTAPIClient
    
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    func execute(_ request: BTShopperInsightsRequest) async throws -> BTShopperInsightsResult {
        // TODO: - Add logic
        .init()
    }
}

class BTShopperInsightsClient_Tests: XCTestCase {
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    var mockAPIClient: MockAPIClient!
    var sut: BTShopperInsightsClient!
    var mockFind: BTFindEligibleMethodsServiceable!
    
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
        mockFind = MockFind(apiClient: mockAPIClient)
        sut = BTShopperInsightsClient(authorization: clientToken, shopperSessionID: "fake-shopper-session-id", apiClient: mockAPIClient, findEligibleMethodService: mockFind)
        sut.apiClient = mockAPIClient
    }
    
    func testGetRecommendedPaymentMethods_withTokenizationKey_returnsError() async {
        let shopperInsightsClient = BTShopperInsightsClient(authorization: "sandbox_merchant_1234567890abc")

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
