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
            BTPayPalCampaign(id: "campaign-123"),
            BTPayPalCampaign(id: "campaign-456")
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
        let amount = purchaseUnits?.first?["amount"] as? [String: Any]
        let payPalCampaigns = input?["paypal_campaigns"] as? [[String: Any]]

        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(customer?["hashedEmail"] as? String, "test-hashed-email.com")
        XCTAssertEqual(customer?["paypalAppInstalled"] as? Bool, true)
        XCTAssertEqual(amount?["value"] as? String, "5.00")
        XCTAssertEqual(payPalCampaigns?.count, 2)
        XCTAssertEqual(payPalCampaigns?.first?["id"] as? String, "campaign-123")
        XCTAssertEqual(payPalCampaigns?.last?["id"] as? String, "campaign-456")
    }
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithNilData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: nil
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
        let payPalCampaigns = input?["paypal_campaigns"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertNil(purchaseUnits)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNil(payPalCampaigns)
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
        let payPalCampaigns = input?["paypal_campaigns"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertEqual(purchaseUnits?.count, 0)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNil(payPalCampaigns)
    }
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithEmptyCampaigns() {
        let request = BTCustomerSessionRequest(
            hashedEmail: "test-hashed-email.com",
            hashedPhoneNumber: nil,
            payPalAppInstalled: true,
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
        let payPalCampaigns = input?["paypal_campaigns"] as? [[String: Any]]
        
        XCTAssertNotNil(payPalCampaigns)
        XCTAssertEqual(payPalCampaigns?.count, 0)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
    
    func testEncodingGenerateCustomerRecommendationsGraphQLBodyWithSingleCampaign() {
        let request = BTCustomerSessionRequest(
            hashedEmail: "test-hashed-email.com",
            hashedPhoneNumber: nil,
            payPalAppInstalled: true,
            venmoAppInstalled: nil,
            purchaseUnits: nil,
            payPalCampaigns: [
                BTPayPalCampaign(id: "single-campaign-555")
            ]
        )
        
        let body = GenerateCustomerRecommendationsGraphQLBody(request: request, sessionID: sessionID)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let payPalCampaigns = input?["paypal_campaigns"] as? [[String: Any]]
        
        XCTAssertEqual(payPalCampaigns?.count, 1)
        XCTAssertEqual(payPalCampaigns?.first?["id"] as? String, "single-campaign-555")
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
}
