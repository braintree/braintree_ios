import XCTest

@testable import BraintreeTestShared
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalNativeTokenizationClient_Tests: XCTestCase {

    func testTokenizationRequestSuccessfulResponse() throws {
        let mockClient = try XCTUnwrap(MockAPIClient(authorization: "development_client_key"))
        let mockNonce = "mock-nonce"
        let mockCorrelationId = "mock-corrID"

        let responseData = try XCTUnwrap("""
        {
            "paypalAccounts": [{
                "consumed": 0,
                "description": "PayPal",
                "details": {
                    "correlationId": "\(mockCorrelationId)",
                },
                "nonce": "\(mockNonce)",
                "type": "PayPalAccount",
            }]
        }
        """.data(using: .utf8))
        mockClient.cannedResponseBody = BTJSON(data: responseData)

        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: mockClient)

        // Our mock does not care about the specific request, but we want to make sure
        // a successful response is vended through the completion handler
        // We don't need to use `waitForExpectations` here because the mock will vend a response
        // synchronously
        tokenizationClient.tokenize(request: BTPayPalNativeCheckoutRequest(amount: "1"), returnURL: "a-fake-return-url") { result in
            switch result {
            case .success(let account):
                XCTAssertEqual(account.nonce, mockNonce)
                XCTAssertEqual(account.type, "PayPal")
                XCTAssertEqual(account.clientMetadataID, mockCorrelationId)              
            case .failure:
                XCTFail("Successful mock did not vend a PayPal account nonce")
            }
        }
    }

    func testTokenizationRequestFailureResponse() throws {
        let mockClient = try XCTUnwrap(MockAPIClient(authorization: "development_client_key"))
        let mockCorrelationId = "mock-corrID"

        /// Same response data as the successful response, but the nonce is absent
        let responseData = try XCTUnwrap("""
        {
            "paypalAccounts": [{
                "consumed": 0,
                "description": "PayPal",
                "details": {
                    "correlationId": "\(mockCorrelationId)",
                },
                "type": "PayPalAccount",
            }]
        }
        """.data(using: .utf8))
        mockClient.cannedResponseBody = BTJSON(data: responseData)
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: mockClient)
        tokenizationClient.tokenize(request: BTPayPalNativeVaultRequest(), returnURL: "a-fake-return-url") { result in
            switch result {
            case .success:
                XCTFail("A response without a nonce string should be a failure")
            case .failure(let error):
                XCTAssertEqual(error, .parsingTokenizationResultFailed)
            }
        }
    }
  
    func testTokenizationRequestFailureResponseForNilReturnUrl() throws {
        let mockClient = try XCTUnwrap(MockAPIClient(authorization: "development_client_key"))
        let mockCorrelationId = "mock-corrID"
        let mockNonce = "mock-nonce"
        let responseData = try XCTUnwrap("""
        {
            "paypalAccounts": [{
                "consumed": 0,
                "description": "PayPal",
                "details": {
                    "correlationId": "\(mockCorrelationId)",
                },
                "nonce": "\(mockNonce)",
                "type": "PayPalAccount",
            }]
        }
        """.data(using: .utf8))
        mockClient.cannedResponseBody = BTJSON(data: responseData)
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: mockClient)
        tokenizationClient.tokenize(request: BTPayPalNativeVaultRequest(), returnURL: nil) { result in
            switch result {
            case .success:
                XCTFail("A response without a nonce string should be a failure")
            case .failure(let error):
                XCTAssertEqual(error, .missingReturnURL)
            }
        }
    }
}
