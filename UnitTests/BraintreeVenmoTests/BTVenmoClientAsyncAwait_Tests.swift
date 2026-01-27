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

    func testTokenize_whenAppSwitchSucceeds_waitsForReturnURL() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Tokenize completes")
        
        Task {
            do {
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
            } catch {
                XCTFail("Failed to simulate return URL: \(error)")
            }
        }

        do {
            let result = try await venmoClient.tokenize(venmoRequest)
            XCTAssertEqual(result.nonce, "fake-venmo-nonce")
            XCTAssertEqual(result.username, "fake-venmo-username")
            expectation.fulfill()
        } catch {
            XCTFail("Tokenize failed: \(error)")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testTokenize_whenAppSwitchCanceled_throwsCanceledError() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Tokenize completes with cancel")
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!
                    )
                }
            } catch {
                XCTFail("Failed to simulate cancel: \(error)")
            }
        }

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
            expectation.fulfill()
        } catch {
            XCTAssertEqual((error as NSError).code, BTVenmoError.canceled.errorCode)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testTokenize_whenReturnURLHasError_throwsError() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Tokenize completes with error")
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!
                    )
                }
            } catch {
                XCTFail("Failed to simulate error: \(error)")
            }
        }

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
            expectation.fulfill()
        } catch {
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // MARK: - Vaulting Tests

    func testTokenize_withVaultTrue_andTokenizationKey_doesNotVault() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        venmoRequest.vault = true

        let expectation = expectation(description: "Tokenize completes without vaulting")
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)

                await MainActor.run {
                    BTVenmoClient.handleReturnURL(
                        URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=test-nonce&username=testuser")!
                    )
                }
            } catch {
                XCTFail("Failed to simulate return: \(error)")
            }
        }

        do {
            let result = try await venmoClient.tokenize(venmoRequest)
            XCTAssertEqual(result.nonce, "test-nonce")
            XCTAssertEqual(result.username, "testuser")
            XCTAssertNotEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/venmo_accounts")
            expectation.fulfill()
        } catch {
            XCTFail("Tokenize failed: \(error)")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testTokenize_withVaultTrue_andClientToken_vaultsNonce() async {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        venmoRequest.vault = true

        let expectation = expectation(description: "Tokenize completes with vaulting")
        
        Task {
            do {
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
            } catch {
                XCTFail("Failed to simulate return: \(error)")
            }
        }

        do {
            let result = try await venmoClient.tokenize(venmoRequest)
            XCTAssertEqual(result.nonce, "vaulted-nonce")
            XCTAssertEqual(result.username, "venmojoe")
            XCTAssertTrue(result.isDefault)
            expectation.fulfill()
        } catch {
            XCTFail("Tokenize failed: \(error)")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // MARK: - Continuation Cleanup Tests

    func testTokenize_multipleCalls_eachGetsSeparateContinuation() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let firstExpectation = expectation(description: "First tokenize completes")
        
        // First tokenize call
        Task {
            do {
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
            } catch {
                XCTFail("Failed to simulate first return: \(error)")
            }
        }

        do {
            let firstResult = try await venmoClient.tokenize(venmoRequest)
            XCTAssertEqual(firstResult.nonce, "first-nonce")
            XCTAssertNil(venmoClient.appSwitchContinuation)
            firstExpectation.fulfill()
        } catch {
            XCTFail("First tokenize failed: \(error)")
            firstExpectation.fulfill()
        }
        
        await fulfillment(of: [firstExpectation], timeout: 10.0)

        let secondExpectation = expectation(description: "Second tokenize completes")
        
        // Second tokenize call
        Task {
            do {
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
            } catch {
                XCTFail("Failed to simulate second return: \(error)")
            }
        }

        do {
            let secondResult = try await venmoClient.tokenize(venmoRequest)
            XCTAssertEqual(secondResult.nonce, "second-nonce")
            secondExpectation.fulfill()
        } catch {
            XCTFail("Second tokenize failed: \(error)")
            secondExpectation.fulfill()
        }
        
        await fulfillment(of: [secondExpectation], timeout: 10.0)
    }

    func testTokenize_success_sendsAnalyticsEvents() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Tokenize completes with analytics")
        
        Task {
            do {
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
            } catch {
                XCTFail("Failed to simulate return: \(error)")
            }
        }

        do {
            _ = try await venmoClient.tokenize(venmoRequest)
            
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchSucceeded))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.handleReturnStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeSucceeded))
            expectation.fulfill()
        } catch {
            XCTFail("Tokenize failed: \(error)")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}
