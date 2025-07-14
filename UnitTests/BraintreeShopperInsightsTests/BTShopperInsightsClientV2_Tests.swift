import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights
@testable import BraintreeCore

class BTShopperInsightsClientV2_Tests: XCTestCase {
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    let sessionID = "some-session-id"
    let customerSessionRequest = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        payPalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTPurchaseUnit(
                amount: "10.00",
                currencyCode: "USD"
            ),
            BTPurchaseUnit(
                amount: "20.00",
                currencyCode: "USD"
            )
        ]
    )
    
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
    
    func testCreateCustomerSession_whenSuccessful_returnsSessionID() async throws {
        let expectedSessionID = "expected-session-id"
        let mockCreateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "createCustomerSession": [
                        "sessionId": "expected-session-id"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockCreateCustomerSessionResponse
        
        let sessionID = try await sut.createCustomerSession(request: customerSessionRequest)
        
        XCTAssertEqual(expectedSessionID, sessionID)
    }
    
    func testCreateCustomerSession_whenFails_throwsAnError() async throws {
        let mockError = NSError(domain: "test-error-domain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
                
        do {
            _ = try await sut.createCustomerSession(request: customerSessionRequest)
            XCTFail("Expected error to be thrown.")
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
        }
    }
    
    func testUpdateCustomerSession_whenSuccessful_returnsSessionID() async throws {
        let expectedSessionID = "expected-session-id"
        let mockUpdateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "updateCustomerSession": [
                        "sessionId": "expected-session-id"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockUpdateCustomerSessionResponse
        
        let sessionID = try await sut.updateCustomerSession(request: customerSessionRequest, sessionID: sessionID)
        XCTAssertEqual(expectedSessionID, sessionID)
    }
    
    func testUpdateCustomerSession_whenFails_throwsAnError() async throws {
        let mockError = NSError(domain: "update-customer-session-test-error", code: 2, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
        
        do {
            _ = try await sut.updateCustomerSession(request: customerSessionRequest, sessionID: sessionID)
            XCTFail("Expected error to be thrown.")
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
        }
    }
    
    func testCustomerRecommendationsGenerate_withResult() async {
        let generateCustomerRecommendationResponse = BTJSON(
            value: [
                "data": [
                    "generateCustomerRecommendations": [
                        "sessionId": "test-session-id-123",
                        "isInPayPalNetwork": true,
                        "paymentRecommendations": [
                            [
                                "paymentOption": "PayPal",
                                "recommendedPriority": 1
                            ],
                            [
                                "paymentOption": "Venmo",
                                "recommendedPriority": 2
                            ]
                        ]
                    ]
                ]
            ]
        )

        mockAPIClient.cannedResponseBody = generateCustomerRecommendationResponse
        mockAPIClient.cannedResponseError = nil

        do {
            let result = try await sut.generateCustomerRecommendations(
                request: customerSessionRequest,
                sessionID: sessionID
            )

            XCTAssertEqual(result?.sessionID, "test-session-id-123")
            XCTAssertTrue((result?.isInPayPalNetwork != nil))

            guard let recommendations = result?.paymentRecommendations else {
                XCTFail("Expected paymentRecommendations to be non-nil")
                return
            }

            XCTAssertEqual(recommendations.count, 2)

            XCTAssertEqual(recommendations[0].paymentOption, "PayPal")
            XCTAssertEqual(recommendations[0].recommendedPriority, 1)

            XCTAssertEqual(recommendations[1].paymentOption, "Venmo")
            XCTAssertEqual(recommendations[1].recommendedPriority, 2)

        } catch {
            XCTFail("Expected no error, but got: \(error)")
        }
    }

    func testGenerateCustomerRecommendations_withError() async {
        let expectedError = NSError(domain: "test-domain", code: 42, userInfo: nil)
        mockAPIClient.cannedResponseError = expectedError

        do {
            _ = try await sut.generateCustomerRecommendations(
                request: BTCustomerSessionRequest(),
                sessionID: "test-session-id"
            )
            XCTFail("Expected error to be thrown, but got success")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        } catch {
            XCTFail("Expected NSError but got a different error: \(error)")
        }
    }
}
