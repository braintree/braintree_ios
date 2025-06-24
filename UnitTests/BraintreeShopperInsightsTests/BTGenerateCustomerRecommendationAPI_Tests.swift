import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTGenerateCustomerRecommendationApi_Tests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTCustomerRecommendationsAPI!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 2)
    let sessionID = "shopper-session-id"
    
    let generateCustomerRecommendationsRequest = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        payPalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTPurchaseUnit(
                amount: "4.50",
                currencyCode: "USD"
            ),
            BTPurchaseUnit(
                amount: "12.00",
                currencyCode: "USD"
            )
        ]
    )
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTCustomerRecommendationsAPI(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockAPIClient = nil
    }
    
    func testExecute_whenGenerateCustomerRecommendationsRequestIsValid_returnsSuccessfulBTCustomerRecommendationsResult() async throws {
        let expectedSessionID = "session-id"
        let mockGenerateCustomerRecommendationsResponse = BTJSON(
            value: [
                "data": [
                    "generateCustomerRecommendations": [
                        "sessionId": expectedSessionID,
                        "isInPayPalNetwork": true,
                        "paymentRecommendations": [
                            [
                                "paymentOption": "PAYPAL",
                                "recommendedPriority": 1
                            ]
                        ]
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockGenerateCustomerRecommendationsResponse
        
        let expectedResult = try await sut.execute(generateCustomerRecommendationsRequest, sessionID: sessionID)
        
        XCTAssertEqual(expectedResult?.sessionID, expectedSessionID)
        XCTAssertEqual(expectedResult?.isInPayPalNetwork, true)
        XCTAssertEqual(expectedResult?.paymentRecommendations.first?.paymentOption, "PAYPAL")
        XCTAssertEqual(expectedResult?.paymentRecommendations.first?.recommendedPriority, 1)
    }
    
    func testExecute_whenGenerateCustomerRecommendationsRequestIsInvalid_throwsBTHTTPError() async {
        let mockGenerateCustomerRecommendationsResponse = BTJSON(
            value: [
                "data": [
                    "generateCustomerRecommendations": [
                        "random-session-id": "invalid-session-id",
                        "isInPayPalNetwork": nil,
                        "paymentRecommendations": nil
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockGenerateCustomerRecommendationsResponse
        
        do {
            let _ = try await sut.execute(generateCustomerRecommendationsRequest, sessionID: sessionID)
            XCTFail("Expected BTHTTPError to be thrown")
        } catch let error as BTHTTPError {
            XCTAssertEqual(error.errorCode, BTHTTPError.httpResponseInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "Unable to create HTTPURLResponse from response data.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExecute_whenEmptyResponseBodyReturned_throwsBTShopperInsightsError() async {
        mockAPIClient.cannedResponseBody = nil
        
        do {
            _ = try await sut.execute(generateCustomerRecommendationsRequest, sessionID: sessionID)
            XCTFail("Expected an error")
        } catch let error as BTShopperInsightsError {
            XCTAssertEqual((error as NSError).domain, BTShopperInsightsError.errorDomain)
            XCTAssertEqual(error.errorCode, BTShopperInsightsError.emptyBodyReturned.errorCode)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExceute_whenGenerateCustomerRecommendationsAPIFails_throwsNSError() async {
        let mockError = NSError(domain: "generate-customer-recommendations-error", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
        
        do {
            _ = try await sut.execute(generateCustomerRecommendationsRequest, sessionID: sessionID)
            XCTFail("Expected an error")
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
        }
    }
}

