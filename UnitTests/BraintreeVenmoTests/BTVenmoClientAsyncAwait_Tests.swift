import XCTest
import UIKit
@testable import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

final class BTVenmoClientAsyncAwait_Tests: XCTestCase {
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

        venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoClient = BTVenmoClient(
            authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn",
            universalLink: URL(string: "https://mywebsite.com/braintree-payments")!
        )
        venmoClient.apiClient = mockAPIClient
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
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
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(nsError.code, BTVenmoError.fetchConfigurationFailed.errorCode)
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
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(nsError.code, BTVenmoError.disabled.errorCode)
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
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(nsError.code, BTVenmoError.appSwitchFailed.errorCode)
        }
    }

    func testTokenize_whenAppSwitchSucceeds_waitsForReturnURL() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertNotNil(BTVenmoClient.venmoClient)

        mockAPIClient.cannedResponseBody = BTJSON(value: [
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

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success(let venmoNonce):
            XCTAssertEqual(venmoNonce.nonce, "fake-venmo-nonce")
            XCTAssertEqual(venmoNonce.username, "fake-venmo-username")
        case .failure(let error):
            XCTFail("Tokenize task failed or timed out: \(error)")
        }
    }

    func testTokenize_whenAppSwitchCanceled_throwsCanceledError() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        await MainActor.run {
            BTVenmoClient.handleReturnURL(
                URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!
            )
        }

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success:
            XCTFail("Expected error to be thrown")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, BTVenmoError.canceled.errorCode)
        }
    }

    func testTokenize_whenReturnURLHasError_throwsError() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        await MainActor.run {
            BTVenmoClient.handleReturnURL(
                URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!
            )
        }

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success:
            XCTFail("Expected error to be thrown")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Vaulting Tests

    func testTokenize_withVaultTrue_andTokenizationKey_doesNotVault() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        await MainActor.run {
            BTVenmoClient.handleReturnURL(
                URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=test-nonce&username=testuser")!
            )
        }

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success(let venmoNonce):
            XCTAssertEqual(venmoNonce.nonce, "test-nonce")
            XCTAssertEqual(venmoNonce.username, "testuser")
            XCTAssertNotEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/venmo_accounts")
        case .failure(let error):
            XCTFail("Tokenize task failed: \(error)")
        }
    }

    func testTokenize_withVaultTrue_andClientToken_vaultsNonce() async {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        mockAPIClient.cannedResponseBody = BTJSON(value: [
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

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success(let venmoNonce):
            XCTAssertEqual(venmoNonce.nonce, "vaulted-nonce")
            XCTAssertEqual(venmoNonce.username, "venmojoe")
            XCTAssertTrue(venmoNonce.isDefault)
        case .failure(let error):
            XCTFail("Tokenize task failed: \(error)")
        }
    }

    // MARK: - Continuation Cleanup Tests

    func testTokenize_multipleCalls_eachGetsSeparateContinuation() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        // First tokenize call
        let firstTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        mockAPIClient.cannedResponseBody = BTJSON(value: [
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

        let firstResult = await Task {
            try await withTimeout(seconds: 2) {
                try await firstTask.value
            }
        }.result

        switch firstResult {
        case .success(let venmoNonce):
            XCTAssertEqual(venmoNonce.nonce, "first-nonce")
        case .failure(let error):
            XCTFail("First tokenize failed: \(error)")
        }

        XCTAssertNil(venmoClient.appSwitchContinuation)

        // Second tokenize call
        let secondTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        mockAPIClient.cannedResponseBody = BTJSON(value: [
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

        let secondResult = await Task {
            try await withTimeout(seconds: 2) {
                try await secondTask.value
            }
        }.result

        switch secondResult {
        case .success(let venmoNonce):
            XCTAssertEqual(venmoNonce.nonce, "second-nonce")
        case .failure(let error):
            XCTFail("Second tokenize failed: \(error)")
        }
    }

    func testTokenize_success_sendsAnalyticsEvents() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let tokenizeTask = Task {
            try await venmoClient.tokenize(venmoRequest)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        mockAPIClient.cannedResponseBody = BTJSON(value: [
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

        let result = await Task {
            try await withTimeout(seconds: 2) {
                try await tokenizeTask.value
            }
        }.result

        switch result {
        case .success:
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.appSwitchSucceeded))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.handleReturnStarted))
            XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTVenmoAnalytics.tokenizeSucceeded))
        case .failure(let error):
            XCTFail("Tokenize task failed: \(error)")
        }
    }

    // MARK: - Helper Methods

    func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(
                    domain: "TestTimeout",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Operation timed out"]
                )
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
