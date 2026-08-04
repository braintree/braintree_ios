import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class CreateCustomerSessionMutationGraphQLBody_Tests: XCTestCase {
    
    let request = BTCustomerSessionRequest(
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
        ],
        payPalCampaigns: [
            BTShopperInsightsCampaign(id: "campaign-123-id"),
            BTShopperInsightsCampaign(id: "campaign-456-id")
        ]
    )
    let expectedQuery = """
            mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                createCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithFullData() {
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        
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
        XCTAssertEqual(customer?["hashedEmail"] as? String, "test-hashed-email.com")
        XCTAssertEqual(customer?["paypalAppInstalled"] as? Bool, true)
        XCTAssertEqual(payPalCampaigns?.count, 2)
        XCTAssertEqual(payPalCampaigns?[0]["id"] as? String, "campaign-123-id")
        XCTAssertEqual(payPalCampaigns?[1]["id"] as? String, "campaign-456-id")
        XCTAssertEqual(amount?["value"] as? String, "10.00")
    }
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithNilData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: nil,
            payPalCampaigns: [BTShopperInsightsCampaign(id: "campaign-123-id")]
        )
        
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let payPalCampaigns = input?["paypalCampaigns"] as? [[String: Any]]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNotNil(customer)
        XCTAssertEqual(payPalCampaigns?.count, 1)
        XCTAssertEqual(payPalCampaigns?.first?["id"] as? String, "campaign-123-id")
        XCTAssertNil(purchaseUnits)
    }
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithEmptyData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: [],
            payPalCampaigns: []
        )
        
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let payPalCampaigns = input?["paypalCampaigns"] as? [[String: Any]]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNotNil(customer)
        XCTAssertNil(payPalCampaigns)
        XCTAssertEqual(purchaseUnits?.count, 0)
    }

    func testEncodingCreateCustomerSessionGraphQLBodyWithEmptyPayPalCampaignIDsOmitsThem() {
        let request = BTCustomerSessionRequest(
            payPalCampaigns: [
                BTShopperInsightsCampaign(id: ""),
                BTShopperInsightsCampaign(id: "")
            ]
        )

        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }

        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]

        XCTAssertNil(input?["paypalCampaigns"])
    }

    func testEncodingCreateCustomerSessionGraphQLBodyWithWhitespacePayPalCampaignIDsPreservesIDs() {
        let request = BTCustomerSessionRequest(
            payPalCampaigns: [
                BTShopperInsightsCampaign(id: " campaign-123-id "),
                BTShopperInsightsCampaign(id: "   ")
            ]
        )

        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }

        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let payPalCampaigns = input?["paypalCampaigns"] as? [[String: Any]]

        XCTAssertEqual(payPalCampaigns?.count, 2)
        XCTAssertEqual(payPalCampaigns?[0]["id"] as? String, " campaign-123-id ")
        XCTAssertEqual(payPalCampaigns?[1]["id"] as? String, "   ")
    }
}
