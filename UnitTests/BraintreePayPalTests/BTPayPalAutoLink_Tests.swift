import XCTest
@testable import BraintreePayPal
@testable import BraintreeTestShared
@testable import BraintreeCore

class BTPayPalAutoLink_Tests: XCTestCase {

    var mockAPIClient: MockAPIClient!
    var payPalClient: BTPayPalClient!
    var mockPendingStore: MockPendingStore!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var fakeApplication: FakeApplication!
    let authorization = "development_testing_integration_merchant_id"

    let nonceResponseBody = BTJSON(value: [
        "paypalAccounts": [["nonce": "a-nonce", "type": "PayPalAccount"]]
    ] as [String: Any])

    let hermesResponseBody = BTJSON(value: [
        "paymentResource": ["redirectUrl": "http://fakeURL.com"]
    ] as [String: Any])

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["environment": "offline"],
            "merchantId": "testMerchantId"
        ] as [String: Any])

        payPalClient = BTPayPalClient(authorization: authorization, universalLink: URL(string: "https://www.paypal.com")!)
        payPalClient.apiClient = mockAPIClient

        mockWebAuthenticationSession = MockWebAuthenticationSession()
        payPalClient.webAuthenticationSession = mockWebAuthenticationSession

        mockPendingStore = MockPendingStore()
        BTPayPalClient.pendingStore = mockPendingStore

        fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication
    }

    override func tearDown() {
        BTPayPalClient.payPalClient = nil
        BTPayPalClient.pendingStore = BTPayPalInMemoryPendingStore()
        super.tearDown()
    }

    // MARK: - Helpers

    func makeValidSession(baToken: String = "BA-123", correlationID: String? = "corr-id") -> BTPayPalAppSwitchSession {
        BTPayPalAppSwitchSession(baToken: baToken, correlationID: correlationID, startedAt: Date())
    }

    func makeExpiredSession() -> BTPayPalAppSwitchSession {
        BTPayPalAppSwitchSession(
            baToken: "BA-EXPIRED",
            correlationID: nil,
            startedAt: Date(timeIntervalSinceNow: -(BTPayPalAppSwitchSession.ttl + 1))
        )
    }

    // MARK: - Persist before app switch (launchPayPalApp)

    func testLaunchPayPalApp_whenVaultRequest_storesPendingSession() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": ["paypalAppApprovalUrl": "https://paypal.com/some-path?ba_token=BA-ABC"]
        ] as [String: Any])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true, userAuthenticationEmail: "user@test.com")
        let expectation = expectation(description: "tokenize called")
        expectation.isInverted = true

        payPalClient.tokenize(vaultRequest) { _, _ in expectation.fulfill() }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(mockPendingStore.storeCallCount, 1)
        XCTAssertEqual(mockPendingStore.storedSession?.baToken, "BA-ABC")
    }

    func testLaunchPayPalApp_whenCheckoutRequest_doesNotStorePendingSession() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://paypal.com/checkout?token=EC-123",
                "launchPayPalApp": true
            ]
        ] as [String: Any])

        let checkoutRequest = BTPayPalCheckoutRequest(amount: "10.00")
        let expectation = expectation(description: "tokenize called")
        expectation.isInverted = true

        payPalClient.tokenize(checkoutRequest) { _, _ in expectation.fulfill() }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(mockPendingStore.storeCallCount, 0)
    }

    func testLaunchPayPalApp_storedSession_containsCorrectCorrelationID() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": ["paypalAppApprovalUrl": "https://paypal.com/some-path?ba_token=BA-ABC"]
        ] as [String: Any])

        let vaultRequest = BTPayPalVaultRequest(
            enablePayPalAppSwitch: true,
            riskCorrelationID: "fake-correlation-id",
            userAuthenticationEmail: "user@test.com"
        )
        let expectation = expectation(description: "tokenize called")
        expectation.isInverted = true

        payPalClient.tokenize(vaultRequest) { _, _ in expectation.fulfill() }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(mockPendingStore.storedSession?.correlationID, "fake-correlation-id")
    }

    // MARK: - Path 1: applicationDidBecomeActive guard

    func testApplicationDidBecomeActive_whenNotActiveClient_doesNotAttemptAutoLink() {
        BTPayPalClient.payPalClient = nil
        mockPendingStore.storedSession = makeValidSession()

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        let expectation = expectation(description: "No auto-link POST should fire")
        expectation.isInverted = true
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
        XCTAssertEqual(mockPendingStore.clearCallCount, 0)
    }

    func testApplicationDidBecomeActive_whenNoPendingSession_doesNotPostToPayPalAccounts() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = nil

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        let expectation = expectation(description: "No POST should fire")
        expectation.isInverted = true
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
    }

    func testApplicationDidBecomeActive_whenExpiredSession_clearsPendingStoreAndDoesNotPost() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeExpiredSession()

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        let expectation = expectation(description: "No POST should fire after expiry clear")
        expectation.isInverted = true
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(mockPendingStore.clearCallCount, 1)
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
    }

    func testApplicationDidBecomeActive_whenValidSession_andBTGWSucceeds_deliversNonceViaAppSwitchCompletion() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let expectation = expectation(description: "Nonce delivered via appSwitchCompletion")
        payPalClient.appSwitchCompletion = { nonce, error in
            XCTAssertNotNil(nonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 2)
    }

    func testApplicationDidBecomeActive_whenValidSession_andBTGWSucceeds_clearsPendingStore() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let expectation = expectation(description: "Store cleared after success")
        payPalClient.appSwitchCompletion = { _, _ in expectation.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 2)

        XCTAssertNil(mockPendingStore.storedSession)
    }

    func testApplicationDidBecomeActive_whenValidSession_andBTGWFails_doesNotCompleteAndKeepsPendingStore() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseError = NSError(domain: "com.test", code: 1)

        let expectation = expectation(description: "Auto-link failure should not complete merchant callback")
        expectation.isInverted = true
        payPalClient.appSwitchCompletion = { _, _ in
            expectation.fulfill()
        }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 0.5)

        XCTAssertNotNil(mockPendingStore.storedSession)
        XCTAssertEqual(mockPendingStore.clearCallCount, 0)
    }

    func testApplicationDidBecomeActive_whenBTGWFails_thenSucceedsOnNextForeground_deliversNonce() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseError = NSError(domain: "com.test", code: 1)

        let firstAttemptExpectation = expectation(description: "First auto-link failure should not complete merchant callback")
        firstAttemptExpectation.isInverted = true
        payPalClient.appSwitchCompletion = { _, _ in
            firstAttemptExpectation.fulfill()
        }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        wait(for: [firstAttemptExpectation], timeout: 0.5)

        XCTAssertNotNil(mockPendingStore.storedSession)

        mockAPIClient.cannedResponseError = nil
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let secondAttemptExpectation = expectation(description: "Second auto-link attempt succeeds")
        payPalClient.appSwitchCompletion = { nonce, error in
            XCTAssertNotNil(nonce)
            XCTAssertNil(error)
            secondAttemptExpectation.fulfill()
        }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        wait(for: [secondAttemptExpectation], timeout: 2)

        XCTAssertNil(mockPendingStore.storedSession)
    }

    func testApplicationDidBecomeActive_whenAlreadyAutoTokenizing_doesNotDuplicateRequest() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let firstCompletion = expectation(description: "First auto-link completes")
        payPalClient.appSwitchCompletion = { _, _ in firstCompletion.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))
        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockPendingStore.clearCallCount, 1)
    }

    // MARK: - Path 1: Analytics

    func testApplicationDidBecomeActive_whenValidSession_sendsAutoLinkStartedAnalytic() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let expectation = expectation(description: "Auto-link completes")
        payPalClient.appSwitchCompletion = { _, _ in expectation.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 2)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.autoLinkStarted))
    }

    func testApplicationDidBecomeActive_whenBTGWSucceeds_sendsAutoLinkSucceededAnalytic() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let expectation = expectation(description: "Auto-link completes")
        payPalClient.appSwitchCompletion = { _, _ in expectation.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 2)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.autoLinkSucceeded))
    }

    func testApplicationDidBecomeActive_whenBTGWFails_sendsAutoLinkFailedAnalytic() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseError = NSError(domain: "com.test", code: 1)

        let expectation = expectation(description: "Auto-link failure should not complete merchant callback")
        expectation.isInverted = true
        payPalClient.appSwitchCompletion = { _, _ in expectation.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        waitForExpectations(timeout: 0.5)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.autoLinkFailed))
    }

    // MARK: - Path 2: Next button tap

    @MainActor
    func testTokenizeVault_whenValidPendingSession_postsToPayPalAccountsNotHermes() async {
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try? await payPalClient.tokenize(vaultRequest)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
    }

    @MainActor
    func testTokenizeVault_whenValidPendingSession_andBTGWSucceeds_returnsNonce() async throws {
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        let nonce = try await payPalClient.tokenize(vaultRequest)

        XCTAssertEqual(nonce.nonce, "a-nonce")
    }

    @MainActor
    func testTokenizeVault_whenValidPendingSession_andBTGWSucceeds_clearsPendingStore() async throws {
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try await payPalClient.tokenize(vaultRequest)

        XCTAssertNil(mockPendingStore.storedSession)
    }

    @MainActor
    func testTokenizeVault_whenValidPendingSession_andBTGWFails_clearsPendingStoreAndFallsThrough() async {
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = hermesResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try? await payPalClient.tokenize(vaultRequest)

        XCTAssertEqual(mockPendingStore.clearCallCount, 1)
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/paypal_hermes/setup_billing_agreement")
    }

    @MainActor
    func testTokenizeVault_whenExpiredPendingSession_clearsPendingStoreAndProceedsToHermes() async {
        mockPendingStore.storedSession = makeExpiredSession()
        mockAPIClient.cannedResponseBody = hermesResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try? await payPalClient.tokenize(vaultRequest)

        XCTAssertEqual(mockPendingStore.clearCallCount, 1)
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/paypal_hermes/setup_billing_agreement")
    }

    @MainActor
    func testTokenizeCheckout_whenPendingSessionExists_ignoresPendingStoreAndPostsToHermes() async {
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "http://fakeURL.com"]
        ] as [String: Any])

        let checkoutRequest = BTPayPalCheckoutRequest(amount: "10.00")
        _ = try? await payPalClient.tokenize(checkoutRequest)

        XCTAssertEqual(mockPendingStore.storeCallCount, 0)
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/paypal_hermes/create_payment_resource")
    }

    // MARK: - Path 2: POST body for auto-link

    @MainActor
    func testTokenizeVault_whenValidPendingSession_sendsBATokenInPostBody() async {
        mockPendingStore.storedSession = makeValidSession(baToken: "BA-SPECIFIC")
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try? await payPalClient.tokenize(vaultRequest)

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String: Any]
        XCTAssertEqual(paypalAccount["billing_agreement_token"] as? String, "BA-SPECIFIC")
    }

    @MainActor
    func testTokenizeVault_whenValidPendingSession_sendsCorrelationIDInPostBody() async {
        mockPendingStore.storedSession = makeValidSession(baToken: "BA-123", correlationID: "my-correlation")
        mockAPIClient.cannedResponseBody = nonceResponseBody

        let vaultRequest = BTPayPalVaultRequest()
        _ = try? await payPalClient.tokenize(vaultRequest)

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String: Any]
        XCTAssertEqual(paypalAccount["correlation_id"] as? String, "my-correlation")
    }

    // MARK: - handleReturnURL race prevention

    func testHandleReturnURL_clearsPendingStoreBeforeTokenizing() {
        mockPendingStore.storedSession = makeValidSession()

        payPalClient.handleReturnURL(URL(string: "https://mycoolwebsite.com/braintree-payments/success")!)

        XCTAssertEqual(mockPendingStore.clearCallCount, 1)
    }

    func testHandleReturnURL_whenCalledWithValidURL_doesNotFireAutoLink() {
        BTPayPalClient.payPalClient = payPalClient
        mockPendingStore.storedSession = makeValidSession()
        mockAPIClient.cannedResponseBody = nonceResponseBody
        payPalClient.payPalRequest = BTPayPalVaultRequest()

        let handleReturnExpectation = expectation(description: "Handle return completes")
        payPalClient.appSwitchCompletion = { _, _ in handleReturnExpectation.fulfill() }

        payPalClient.handleReturnURL(URL(string: "https://mycoolwebsite.com/braintree-payments/success")!)

        wait(for: [handleReturnExpectation], timeout: 2)

        let autoLinkExpectation = expectation(description: "Auto-link should NOT fire")
        autoLinkExpectation.isInverted = true
        payPalClient.appSwitchCompletion = { _, _ in autoLinkExpectation.fulfill() }

        payPalClient.applicationDidBecomeActive(notification: Notification(name: UIApplication.didBecomeActiveNotification))

        wait(for: [autoLinkExpectation], timeout: 0.5)

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.autoLinkStarted))
    }
}
