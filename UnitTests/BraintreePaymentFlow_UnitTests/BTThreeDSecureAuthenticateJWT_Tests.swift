import UIKit
import XCTest

class BTThreeDSecureAuthenticateJWT_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var mockThreeDSecureLookup: BTThreeDSecureLookup!
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNTI0M2RkZGRmNzlkNGFiYmI5YjYwMDUzN2ZkZjQ0ZDViNDg0ODVkOWU0ZjJmYmI3YWM5ZTU2MGE3ZDVhZmM5fGNyZWF0ZWRfYXQ9MjAxNy0wNC0xM1QyMTozOTo0My40MjM4NzE4MTUrMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTJENzJCNjQ4LUI0RkMtNDQ1My1BOURDLTI2QTYyMEVGNjQwNFx1MDAyNm1lcmNoYW50X2FjY291bnRfaWQ9aWRlYWxfZXVyXHUwMDI2bWVyY2hhbnRfaWQ9ZGNwc3B5MmJyd2RqcjNxblx1MDAyNnB1YmxpY19rZXk9OXd3cnpxazN2cjN0NG5jOCIsImNvbmZpZ1VybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kY3BzcHkyYnJ3ZGpyM3FuL2NsaWVudF9hcGkvdjEvY29uZmlndXJhdGlvbiIsImNoYWxsZW5nZXMiOlsiY3Z2IiwicG9zdGFsX2NvZGUiXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOmZhbHNlLCJjb2luYmFzZUVuYWJsZWQiOnRydWUsImNvaW5iYXNlIjp7ImNsaWVudElkIjoiN2U5NWUwZmRkYTE0ODQ2NjU4YjM4Zjc3MmJhMmQzMGNkNzhhOWYyMTQ0YzUzOTA4NmU1NzkwYmYzNzdmYmVlZCIsIm1lcmNoYW50QWNjb3VudCI6ImNvaW5iYXNlLXNhbmRib3gtc2hhcmVkLW1lcmNoYW50QGdldGJyYWludHJlZS5jb20iLCJzY29wZXMiOiJhdXRob3JpemF0aW9uczpicmFpbnRyZWUgdXNlciIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20vY29pbmJhc2Uvb2F1dGgvcmVkaXJlY3QtbGFuZGluZy5odG1sIiwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sImJyYWludHJlZV9hcGkiOnsiYWNjZXNzX3Rva2VuIjoic2FuZGJveF9mN2RyNWNfZHE2c3MyX2prczd4dF80aHNwc2hfcWI3IiwidXJsIjoiaHR0cHM6Ly9wYXltZW50cy5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tIn0sIm1lcmNoYW50SWQiOiJkY3BzcHkyYnJ3ZGpyM3FuIiwidmVubW8iOiJvZmZsaW5lIiwiYXBwbGVQYXkiOnsic3RhdHVzIjoibW9jayIsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJtZXJjaGFudElkZW50aWZpZXIiOiJtZXJjaGFudC5jb20uYnJhaW50cmVlcGF5bWVudHMuc2FuZGJveC5CcmFpbnRyZWUtRGVtbyIsInN1cHBvcnRlZE5ldHdvcmtzIjpbInZpc2EiLCJtYXN0ZXJjYXJkIiwiYW1leCIsImRpc2NvdmVyIl19LCJtZXJjaGFudEFjY291bnRJZCI6ImlkZWFsX2V1ciJ9"
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: tempClientToken)!

        let threeDSecureResult = BTThreeDSecureResult()
        threeDSecureResult.tokenizedCard = BTCardNonce(graphQLJSON: BTJSON(value:
            [
                "token": "fake-lookup-nonce-to-test",
                "creditCard": [
                    "brand": "Visa",
                    "last4": "1111",
                    "binData": [
                        "prepaid": "Yes",
                        "healthcare": "Yes",
                        "debit": "No",
                        "durbinRegulated": "No",
                        "commercial": "Yes",
                        "payroll": "No",
                        "issuingBank": "US",
                        "countryOfIssuance": "USA",
                        "productId": "123"
                    ],
                    "threeDSecureInfo": [
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false,
                    ]
                ]
            ]))
        mockThreeDSecureLookup = BTThreeDSecureLookup()
        mockThreeDSecureLookup.threeDSecureResult = threeDSecureResult
    }
    
    func testThreeDSecureAuthenticateJWT_Success() {
        let authenticateResponseBody = [
            "paymentMethod": [
                "consumed": false,
                "nonce": "fake-nonce-to-test",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ],
                "type": "CreditCard",
            ],
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: authenticateResponseBody)

        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        BTThreeDSecureAuthenticateJWT.authenticateJWT("fake-jwt", with: mockAPIClient, forLookupResult: mockThreeDSecureLookup, success: { (result) in
            XCTAssertEqual(result.tokenizedCard.nonce, "fake-nonce-to-test")
            XCTAssertTrue(result.tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertTrue(result.tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertNil(result.tokenizedCard.threeDSecureInfo.errorMessage)
            authenticateJwtExpectation.fulfill()
        }) { (error) in
            XCTFail()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testThreeDSecureAuthenticateJWT_ReturnsLookupNonce() {
        let authenticationResponseBody = [
            "errors" : [
                [
                    "message" : "test error"
                ]
            ],
            "threeDSecureInfo": [
                "liabilityShiftPossible": true,
                "liabilityShifted": false,
            ],
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: authenticationResponseBody)

        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        BTThreeDSecureAuthenticateJWT.authenticateJWT("fake-jwt", with: mockAPIClient, forLookupResult: mockThreeDSecureLookup, success: { (result) in
            XCTAssertEqual(result.tokenizedCard, self.mockThreeDSecureLookup.threeDSecureResult.tokenizedCard)
            XCTAssertEqual(result.tokenizedCard.threeDSecureInfo.errorMessage, "test error")
            authenticateJwtExpectation.fulfill()
        }) { (error) in
            XCTFail()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testThreeDSecureAuthenticateJWT_FailsWithNoNonce() {
        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        mockThreeDSecureLookup.threeDSecureResult.tokenizedCard = nil
        BTThreeDSecureAuthenticateJWT.authenticateJWT("fake-jwt", with: mockAPIClient, forLookupResult: mockThreeDSecureLookup, success: { (result) in
            XCTFail()
        }) { (error) in
            XCTAssertEqual(error.localizedDescription, "Tokenized card nonce is required")
            authenticateJwtExpectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }
}
