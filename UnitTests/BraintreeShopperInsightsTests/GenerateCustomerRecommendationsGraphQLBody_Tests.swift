import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class GenerateCustomerRecommendationsGraphQLBody_Tests: XCTestCase {
    
    let sessionID = "shopper-session-id"
    let request = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        payPalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTPurchaseUnit(
                amount: "5.00",
                currencyCode: "USD"
            ),
            BTPurchaseUnit(
                amount: "12.00",
                currencyCode: "USD"
            )
        ],
        payPalCampaigns: [
            ShopperInsightsCampaign(id: "campaign-123-id"),
            ShopperInsightsCampaign(id: "campaign-456-id")
        ]
    )
    let expectedQuery = """
            mutation GenerateCustomerRecommendations($input: GenerateCustomerRecommendationsInput!) {
                generateCustomerRecommendations(input: $input) {
                    sessionId
                    isInPayPalNetwork
                    paymentRecommendations {
                        paymentOption
                        recommendedPriority
                    }
                }
            }
            """
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithFullData() {
        let body =  GenerateCustomerRecommendationsGraphQLBody(request: request, sessionID: sessionID)
        
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let payPalCampaigns = input?["paypalCampaigns"] as? [[String: Any]]
        let amount = purchaseUnits?.first?["amount"] as? [String: Any]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(customer?["hashedEmail"] as? String, "test-hashed-email.com")
        XCTAssertEqual(customer?["paypalAppInstalled"] as? Bool, true)
        XCTAssertEqual(payPalCampaigns?.count, 2)
        XCTAssertEqual(payPalCampaigns?[0]["id"] as? String, "campaign-123-id")
        XCTAssertEqual(payPalCampaigns?[1]["id"] as? String, "campaign-456-id")
        XCTAssertEqual(amount?["value"] as? String, "5.00")
    }
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithNilData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: nil,
            payPalCampaigns: []
        )
        
        let body = GenerateCustomerRecommendationsGraphQLBody(request: request, sessionID: sessionID)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let payPalCampaigns = input?["paypalCampaigns"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertNil(purchaseUnits)
        XCTAssertNil(payPalCampaigns)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithEmptyData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: []
        )
        
        let body = GenerateCustomerRecommendationsGraphQLBody(request: request, sessionID: sessionID)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertEqual(purchaseUnits?.count, 0)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
}
