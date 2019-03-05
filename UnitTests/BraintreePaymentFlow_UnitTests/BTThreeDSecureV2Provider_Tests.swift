import UIKit
import XCTest

class BTThreeDSecureV2Provider_Tests: XCTestCase {
    
    var mockAPIClient : MockAPIClient!
    var threeDSecureV2Provider : BTThreeDSecureV2Provider!
    var threeDSecureRequest : BTThreeDSecureRequest!
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNTI0M2RkZGRmNzlkNGFiYmI5YjYwMDUzN2ZkZjQ0ZDViNDg0ODVkOWU0ZjJmYmI3YWM5ZTU2MGE3ZDVhZmM5fGNyZWF0ZWRfYXQ9MjAxNy0wNC0xM1QyMTozOTo0My40MjM4NzE4MTUrMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTJENzJCNjQ4LUI0RkMtNDQ1My1BOURDLTI2QTYyMEVGNjQwNFx1MDAyNm1lcmNoYW50X2FjY291bnRfaWQ9aWRlYWxfZXVyXHUwMDI2bWVyY2hhbnRfaWQ9ZGNwc3B5MmJyd2RqcjNxblx1MDAyNnB1YmxpY19rZXk9OXd3cnpxazN2cjN0NG5jOCIsImNvbmZpZ1VybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kY3BzcHkyYnJ3ZGpyM3FuL2NsaWVudF9hcGkvdjEvY29uZmlndXJhdGlvbiIsImNoYWxsZW5nZXMiOlsiY3Z2IiwicG9zdGFsX2NvZGUiXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOmZhbHNlLCJjb2luYmFzZUVuYWJsZWQiOnRydWUsImNvaW5iYXNlIjp7ImNsaWVudElkIjoiN2U5NWUwZmRkYTE0ODQ2NjU4YjM4Zjc3MmJhMmQzMGNkNzhhOWYyMTQ0YzUzOTA4NmU1NzkwYmYzNzdmYmVlZCIsIm1lcmNoYW50QWNjb3VudCI6ImNvaW5iYXNlLXNhbmRib3gtc2hhcmVkLW1lcmNoYW50QGdldGJyYWludHJlZS5jb20iLCJzY29wZXMiOiJhdXRob3JpemF0aW9uczpicmFpbnRyZWUgdXNlciIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20vY29pbmJhc2Uvb2F1dGgvcmVkaXJlY3QtbGFuZGluZy5odG1sIiwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sImJyYWludHJlZV9hcGkiOnsiYWNjZXNzX3Rva2VuIjoic2FuZGJveF9mN2RyNWNfZHE2c3MyX2prczd4dF80aHNwc2hfcWI3IiwidXJsIjoiaHR0cHM6Ly9wYXltZW50cy5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tIn0sIm1lcmNoYW50SWQiOiJkY3BzcHkyYnJ3ZGpyM3FuIiwidmVubW8iOiJvZmZsaW5lIiwiYXBwbGVQYXkiOnsic3RhdHVzIjoibW9jayIsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJtZXJjaGFudElkZW50aWZpZXIiOiJtZXJjaGFudC5jb20uYnJhaW50cmVlcGF5bWVudHMuc2FuZGJveC5CcmFpbnRyZWUtRGVtbyIsInN1cHBvcnRlZE5ldHdvcmtzIjpbInZpc2EiLCJtYXN0ZXJjYXJkIiwiYW1leCIsImRpc2NvdmVyIl19LCJtZXJjaGFudEFjY291bnRJZCI6ImlkZWFsX2V1ciJ9"
    
    override func setUp() {
        super.setUp()
        threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureV2Provider = BTThreeDSecureV2Provider()
        mockAPIClient = MockAPIClient(authorization: tempClientToken)!
    }
    
    func testThreeDSecureV2Provider_authenticateWithCardinalJWT_Success() {
//        let lookupResponseBody = [
//            "paymentMethod": [
//                "consumed": false,
//                "nonce": "fake-nonce-to-test",
//                "threeDSecureInfo": [
//                    "liabilityShiftPossible": true,
//                    "liabilityShifted": true,
//                    "status": "authenticate_successful",
//                ],
//                "type": "CreditCard",
//            ],
//            "success": true,
//            "threeDSecureInfo":     [
//                "liabilityShiftPossible": true,
//                "liabilityShifted": true,
//            ],
//            "lookup": [
//                "acsUrl": "http://example.com",
//                "termUrl": "http://example.com",
//                "threeDSecureResult": [
//                    "success" : "true"
//                ]
//            ]
//            ] as [String : Any]
//
//        mockAPIClient.cannedResponseBody = BTJSON(value: lookupResponseBody)
//        
//        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
//        
//        let lookupExpectation = self.expectation(description: "Will perform lookup completion.")
//        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")
//        
//        driver.performThreeDSecureLookup(threeDSecureRequest, additionalParameters: nil) { (lookup, error) in
//            guard let lookup = lookup else {
//                XCTFail("Error generating lookup result.")
//                return
//            }
//            
//            self.threeDSecureV2Provider.authenticateCardinalJWT("fake-jwt", forLookupResult: lookup, with: self.mockAPIClient, success: { (result) in
//                XCTAssertEqual(result.tokenizedCard.nonce, "fake-nonce-to-test")
//                XCTAssertEqual(result.success, true)
//                XCTAssertEqual(result.liabilityShifted, true)
//                XCTAssertEqual(result.liabilityShiftPossible, true)
//                authenticateJwtExpectation.fulfill()
//            }) { (error) in
//                XCTFail()
//                authenticateJwtExpectation.fulfill()
//            }
//            
//            lookupExpectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 4, handler: nil)
    }

    func testThreeDSecureV2Provider_authenticateWithCardinalJWT_FailsWithErrorDescription() {
        let lookupResponseBody = [
            "paymentMethod": [
                "consumed": false,
                "nonce": "fake-nonce-to-test",
                "threeDSecureInfo": [
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                ],
                "type": "CreditCard",
            ],
            "success": false,
            "error" : [
                "message" : "test error"
            ],
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "acsUrl": "http://example.com",
                "termUrl": "http://example.com",
            ]
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: lookupResponseBody)

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        let lookupExpectation = self.expectation(description: "Will perform lookup completion.")
        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")
        
        driver.performThreeDSecureLookup(threeDSecureRequest, additionalParameters: nil) { (lookup, error) in
            guard let lookup = lookup else {
                XCTFail("Error generating lookup result.")
                return
            }

            self.threeDSecureV2Provider.authenticateCardinalJWT("fake-jwt", forLookupResult: lookup, with: self.mockAPIClient, success: { (result) in
                XCTFail()
                authenticateJwtExpectation.fulfill()
            }) { (error) in
                XCTAssertEqual(error.localizedDescription, "test error")
                authenticateJwtExpectation.fulfill()
            }

            lookupExpectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }
    
}
