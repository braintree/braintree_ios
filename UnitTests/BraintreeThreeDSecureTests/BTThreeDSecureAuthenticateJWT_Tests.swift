import UIKit
import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeThreeDSecure

class BTThreeDSecureAuthenticateJWT_Tests: XCTestCase {
    var mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.token(withVersion: 3))
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

    func testThreeDSecureAuthenticateJWT_Success() async {
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

        let result = try? await BTThreeDSecureAuthenticateJWT.authenticate(
            jwt: "fake-jwt",
            withAPIClient: mockAPIClient,
            forResult: threeDSecureLookupResult
        )

        guard let tokenizedCard = result?.tokenizedCard else { XCTFail(); return }
        XCTAssertEqual(tokenizedCard.nonce, "fake-nonce-to-test")
        XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShifted)
        XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
        XCTAssertNil(result?.errorMessage)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthSucceeded))
    }

    func testThreeDSecureAuthenticateJWT_ReturnsLookupNonce_withErrorMessage() async {
        let authenticationResponseBody = [
            "errors" : [
                [
                    "message" : "test error"
                ]
            ]
            ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: authenticationResponseBody)

        let result = try? await BTThreeDSecureAuthenticateJWT.authenticate(
            jwt: "fake-jwt",
            withAPIClient: mockAPIClient,
            forResult: threeDSecureLookupResult
        )

        XCTAssertEqual(result?.tokenizedCard, self.threeDSecureLookupResult.tokenizedCard)
        XCTAssertEqual(result?.errorMessage, "test error")
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthFailed))
    }

    func testThreeDSecureAuthenticateJWT_FailsWithNoNonce() async {
        do {
            _ = try await BTThreeDSecureAuthenticateJWT.authenticate(
                jwt: "fake-jwt",
                withAPIClient: mockAPIClient,
                forResult: BTThreeDSecureResult(json: BTJSON())
            )
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.localizedDescription, "Tokenized card nonce is required.")
        }

        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.jwtAuthFailed))
    }
}
