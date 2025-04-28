import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights
@testable import BraintreeCore

class BTShopperInsightsClientV2_Tests: XCTestCase {
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    let sessionID = "some-session-id"
    
    var mockAPIClient: MockAPIClient!
    var sut: BTShopperInsightsClientV2!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTShopperInsightsClientV2(apiClient: mockAPIClient!)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Analytics
    
    func testSendPayPalPresentedEvent_whenExperimentTypeIsControl_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .control,
            pageType: .about
        )
        
        sut.sendPresentedEvent(for: .payPal, presentmentDetails: presentmentDetails, sessionID: sessionID)
        
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
        
        sut.sendPresentedEvent(for: .payPal, presentmentDetails: presentmentDetails, sessionID: sessionID)
        
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "test" }
            ]
        """)
    }

    func testSendPayPalSelectedEvent_sendsAnalytic() {
        sut.sendSelectedEvent(for: .payPal, sessionID: sessionID)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-selected")
        XCTAssertEqual(mockAPIClient.postedShopperSessionID, sessionID)
        XCTAssertEqual(mockAPIClient.postedButtonType, "PayPal")
    }

    func testSendVenmoPresentedEvent_sendsAnalytic() {
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .control,
            pageType: .about
        )
        
        sut.sendPresentedEvent(for: .venmo, presentmentDetails: presentmentDetails, sessionID: sessionID)
        
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
        
        sut.sendPresentedEvent(for: .venmo, presentmentDetails: presentmentDetails, sessionID: sessionID)
        
        XCTAssertEqual(mockAPIClient.postedMerchantExperiment,
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "test" }
            ]
        """)
    }
    
    func testSendVenmoSelectedEvent_sendsAnalytic() {
        sut.sendSelectedEvent(for: .venmo, sessionID: sessionID)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first, "shopper-insights:button-selected")
        XCTAssertEqual(mockAPIClient.postedButtonType, "Venmo")
        XCTAssertEqual(mockAPIClient.postedShopperSessionID, sessionID)
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
