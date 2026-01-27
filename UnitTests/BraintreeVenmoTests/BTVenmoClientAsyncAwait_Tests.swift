import XCTest
import UIKit
@testable import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTVenmoClient_AsyncAwait_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var venmoRequest: BTVenmoRequest!
    var venmoClient: BTVenmoClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo": [
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
        venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
    }

    override func tearDown() {
        BTVenmoClient.venmoClient = nil
        super.tearDown()
    }

    // MARK: - Configuration Tests

    func testTokenize_whenRemoteConfigurationFetchFails_throwsError() async {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "test", code: 0, userInfo: nil)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, BTVenmoError.errorDomain)
            XCTAssertEqual((error as NSError).code, BTVenmoError.fetchConfigurationFailed.errorCode)
        }
    }

    func testTokenize_whenVenmoConfigurationDisabled_throwsError() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, BTVenmoError.errorDomain)
            XCTAssertEqual((error as NSError).code, BTVenmoError.disabled.errorCode)
        }
    }

    // MARK: - App Switch Tests

    func testTokenize_whenAppSwitchFails_throwsError() async {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccess = false
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, BTVenmoError.errorDomain)
            XCTAssertEqual((error as NSError).code, BTVenmoError.appSwitchFailed.errorCode)
        }
    }

    func testTokenize_whenAppSwitchSucceeds_waitsForReturnURL() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)
                
                self.mockAPIClient.cannedResponseBody = BTJSON(value: [
                    "data": [
                        "node": [
                            "paymentMethodId": "fake-venmo-nonce",
                            "userName": "fake-venmo-username"
                        ]
                    ]
                ])

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!
                    )
                }
            }

            let result = try await self.venmoClient.tokenize(self.venmoRequest)
            XCTAssertEqual(result.nonce, "fake-venmo-nonce")
            XCTAssertEqual(result.username, "fake-venmo-username")
        }
    }

    func testTokenize_whenAppSwitchCanceled_throwsCanceledError() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        
        do {
            try await withTimeout(seconds: 5) {
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000)

                    await MainActor.run {
                        BTVenmoClient.handleReturnURL(
                            URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!
                        )
                    }
                }

                _ = try await self.venmoClient.tokenize(self.venmoRequest)
                XCTFail("Expected error to be thrown")
            }
        } catch {
            XCTAssertEqual((error as NSError).code, BTVenmoError.canceled.errorCode)
        }
    }

    func testTokenize_whenReturnURLHasError_throwsError() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        
        do {
            try await withTimeout(seconds: 5) {
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000)

                    await MainActor.run {
                        BTVenmoClient.handleReturnURL(
                            URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!
                        )
                    }
                }

                _ = try await self.venmoClient.tokenize(self.venmoRequest)
                XCTFail("Expected error to be thrown")
            }
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Vaulting Tests

    func testTokenize_withVaultTrue_andTokenizationKey_doesNotVault() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        venmoRequest.vault = true
        
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=test-nonce&username=testuser")!
                    )
                }
            }

            let result = try await self.venmoClient.tokenize(self.venmoRequest)
            XCTAssertEqual(result.nonce, "test-nonce")
            XCTAssertEqual(result.username, "testuser")
            XCTAssertNotEqual(self.mockAPIClient.lastPOSTPath, "v1/payment_methods/venmo_accounts")
        }
    }

    func testTokenize_withVaultTrue_andClientToken_vaultsNonce() async throws {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        venmoRequest.vault = true
        
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)

                self.mockAPIClient.cannedResponseBody = BTJSON(value: [
                    "venmoAccounts": [[
                        "type": "VenmoAccount",
                        "nonce": "vaulted-nonce",
                        "description": "VenmoAccount",
                        "consumed": false,
                        "default": true,
                        "details": [
                            "username": "venmojoe"
                        ]
                    ] as [String: Any]]
                ])

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=original-nonce&username=testuser")!
                    )
                }
            }

            let result = try await self.venmoClient.tokenize(self.venmoRequest)
            XCTAssertEqual(result.nonce, "vaulted-nonce")
            XCTAssertEqual(result.username, "venmojoe")
            XCTAssertTrue(result.isDefault)
        }
    }

    // MARK: - Continuation Cleanup Tests

    func testTokenize_multipleCalls_eachGetsSeparateContinuation() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        // First tokenize call
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)

                self.mockAPIClient.cannedResponseBody = BTJSON(value: [
                    "data": [
                        "node": [
                            "paymentMethodId": "first-nonce",
                            "userName": "first-user"
                        ]
                    ]
                ])

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=first-context")!
                    )
                }
            }

            let firstResult = try await self.venmoClient.tokenize(self.venmoRequest)
            XCTAssertEqual(firstResult.nonce, "first-nonce")
            XCTAssertNil(self.venmoClient.appSwitchContinuation)
        }

        // Second tokenize call
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)

                self.mockAPIClient.cannedResponseBody = BTJSON(value: [
                    "data": [
                        "node": [
                            "paymentMethodId": "second-nonce",
                            "userName": "second-user"
                        ]
                    ]
                ])

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=second-context")!
                    )
                }
            }

            let secondResult = try await self.venmoClient.tokenize(self.venmoRequest)
            XCTAssertEqual(secondResult.nonce, "second-nonce")
        }
    }

    func testTokenize_success_sendsAnalyticsEvents() async throws {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        
        try await withTimeout(seconds: 5) {
            Task {
                try await Task.sleep(nanoseconds: 100_000_000)

                self.mockAPIClient.cannedResponseBody = BTJSON(value: [
                    "data": [
                        "node": [
                            "paymentMethodId": "test-nonce",
                            "userName": "test-user"
                        ]
                    ]
                ])

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=test-context")!
                    )
                }
            }

            _ = try await self.venmoClient.tokenize(self.venmoRequest)
            
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeStarted))
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchStarted))
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchSucceeded))
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.handleReturnStarted))
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeSucceeded))
        }
    }
    
    // MARK: - Helper Methods
    
    private func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Add the actual operation
            group.addTask {
                try await operation()
            }
            
            // Add a timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(
                    domain: "TestTimeout",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Test timed out after \(seconds) seconds"]
                )
            }
            
            // Return the first result (either success or timeout)
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
