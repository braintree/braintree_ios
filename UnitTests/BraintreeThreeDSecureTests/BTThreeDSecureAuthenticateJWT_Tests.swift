import UIKit
import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeThreeDSecure

class BTThreeDSecureAuthenticateJWT_Tests: XCTestCase {
    var mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.token(withVersion: 3))!
    var threeDSecureLookupResult: BTThreeDSecureResult!

    override func setUp() {
        super.setUp()
        let jsonString =
            """
            {
                "paymentMethod": {
                    "nonce": "fake-lookup-nonce-to-test"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        threeDSecureLookupResult = BTThreeDSecureResult(json: json)
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
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: authenticateResponseBody)

        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        BTThreeDSecureAuthenticateJWT.authenticate(jwt: "fake-jwt", withAPIClient: mockAPIClient, forResult: threeDSecureLookupResult) { result, error in
            XCTAssertNil(error)
            guard let tokenizedCard = result?.tokenizedCard else { XCTFail(); return }
            XCTAssertEqual(tokenizedCard.nonce, "fake-nonce-to-test")
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertNil(result?.errorMessage)
            authenticateJwtExpectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthSucceeded))
    }

    func testThreeDSecureAuthenticateJWT_ReturnsLookupNonce_withErrorMessage() {
        let authenticationResponseBody = [
            "errors" : [
                [
                    "message" : "test error"
                ]
            ]
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: authenticationResponseBody)

        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        BTThreeDSecureAuthenticateJWT.authenticate(jwt: "fake-jwt", withAPIClient: mockAPIClient, forResult: threeDSecureLookupResult) { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(result?.tokenizedCard, self.threeDSecureLookupResult.tokenizedCard)
            XCTAssertEqual(result?.errorMessage, "test error")
            authenticateJwtExpectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthFailed))
    }

    func testThreeDSecureAuthenticateJWT_FailsWithNoNonce() {
        let authenticateJwtExpectation = self.expectation(description: "Will perform cardinal auth completion.")

        BTThreeDSecureAuthenticateJWT.authenticate(jwt: "fake-jwt", withAPIClient: mockAPIClient, forResult: BTThreeDSecureResult(json: BTJSON())) { result, error in
            XCTAssertNil(result)

            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertEqual(error.localizedDescription, "Tokenized card nonce is required.")
            authenticateJwtExpectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthFailed))
    }
}
