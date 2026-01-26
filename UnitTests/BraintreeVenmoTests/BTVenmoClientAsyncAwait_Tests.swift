import XCTest
import UIKit
@testable import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

final class BTVenmoClientAsyncAwait_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
    var venmoRequest: BTVenmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
    var venmoClient: BTVenmoClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token"
            ]
        ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "createVenmoPaymentContext": [
                    "venmoPaymentContext": [
                        "id": "some-resource-id"
                    ]
                ]
            ]
        ])

        venmoClient = BTVenmoClient(
            authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn",
            universalLink: URL(string: "https://mywebsite.com/braintree-payments")!
        )
        venmoClient.apiClient = mockAPIClient
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
    }

    // MARK: - tokenize async

    func testTokenizeAsync_success_returnsNonce() async throws {
        let expectedNonce = "fake-nonce"
        let expectedUsername = "fake-username"

        let venmoAccountNonce = try await venmoClient.tokenize(venmoRequest)

        // simulate app switch return
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=\(expectedNonce)&username=\(expectedUsername)")!)
        }

        XCTAssertEqual(venmoAccountNonce.nonce, expectedNonce)
        XCTAssertEqual(venmoAccountNonce.username, expectedUsername)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    func testTokenizeAsync_errorFromCreatePaymentContext_propagatesError() async {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "random": [
                    "lady_gaga": "poker_face"
                ]
            ]
        )

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error, got success")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.invalidRedirectURL("").errorCode)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testTokenizeAsync_vaultTrue_setsShouldVaultAndVaults() async throws {
        // use client token for vaulting path
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        venmoRequest.vault = true

        let venmoAccountNonce = try await venmoClient.tokenize(venmoRequest)

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(
                URL(string: "scheme://x-callback-url/vzero/auth/venmo/succeeded_with_payment_context?paymentContextId=some-resource-id")!
            )
        }

        XCTAssertTrue(venmoClient.shouldVault)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
        XCTAssertNotNil(venmoAccountNonce.nonce)
    }

    func testTokenizeAsync_appSwitchFailed_throws() async {
        // FakeApplication will return false for open(url:) when configured
        let failingApplication = FakeApplication()
        failingApplication.cannedOpenURLSuccess = false
        venmoClient.application = failingApplication

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected appSwitchFailed error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.appSwitchFailed.errorCode)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - startVenmoFlow async

    func testStartVenmoFlowAsync_success_waitsForContinuation() async throws {
        let appSwitchURL = URL(string: "https://venmo.example/link")!
        venmoClient.shouldVault = false

       let venmoAccountNonce = try await venmoClient.startVenmoFlow(with: appSwitchURL, shouldVault: false)

        // simulate successful return
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(
                URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
            )
        }

        XCTAssertEqual(venmoAccountNonce.nonce, "fake-nonce")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.appSwitchSucceeded)
    }

    func testStartVenmoFlowAsync_openURLFailure_throws() async {
        let appSwitchURL = URL(string: "https://venmo.example/link")!
        let failingApplication = FakeApplication()
        failingApplication.cannedOpenURLSuccess = false
        venmoClient.application = failingApplication

        do {
            _ = try await venmoClient.startVenmoFlow(with: appSwitchURL, shouldVault: false)
            XCTFail("Expected appSwitchFailed error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.appSwitchFailed.errorCode)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - handleOpen async

    func testHandleOpenAsync_success_withPaymentContext_fetchesNonce() async throws {
        // Configure client token for vault path to exercise query payment context
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        venmoClient.shouldVault = true

        // Call handleOpen async after setting a continuation by starting flow
        let appSwitchURL = URL(string: "https://venmo.example/link")!
        let venmoAccountNonce = try await venmoClient.startVenmoFlow(with: appSwitchURL, shouldVault: true)

        // Now invoke async handleOpen
        try await venmoClient.handleOpen(
            URL(string: "scheme://x-callback-url/vzero/auth/venmo/succeeded_with_payment_context?paymentContextId=some-resource-id")!
        )

        XCTAssertNotNil(venmoAccountNonce.nonce)
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
    }

    func testHandleOpenAsync_canceled_throwsCanceled() async {
        // Prepare continuation by starting flow
        let appSwitchURL = URL(string: "https://venmo.example/link")!

        do {
            _ = try await venmoClient.startVenmoFlow(with: appSwitchURL, shouldVault: false)
            XCTFail("Expected canceled error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.canceled.errorCode)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}


