import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreePayPal
@testable import BraintreePayPalSavedPaymentMethod

@MainActor
final class BTPayPalSavedPaymentMethodViewModel_Tests: XCTestCase {

    // MARK: - Properties

    private let clientToken = TestClientTokenFactory.token(
        withVersion: 3,
        overrides: ["paymentMethodIdJwt": "fake-payment-method-id-jwt"]
    )
    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://example.com/universal-link")!

    private var mockAPIClient: MockAPIClient!
    private var fetchClient: BTPayPalSavedPaymentMethodClient!
    private var urlOpener: MockURLOpener!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        fetchClient = BTPayPalSavedPaymentMethodClient(authorization: clientToken, universalLink: universalLink)
        fetchClient.apiClient = mockAPIClient
        urlOpener = MockURLOpener()
    }

    override func tearDown() {
        mockAPIClient = nil
        fetchClient = nil
        urlOpener = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }
    ) -> BTPayPalSavedPaymentMethodViewModel {
        BTPayPalSavedPaymentMethodViewModel(fetchClient: fetchClient, completion: completion, urlOpener: urlOpener)
    }

    private func makeRequest(amount: String = "55.00", merchantAccountID: String? = nil) -> BTPayPalSavedPaymentMethodRequest {
        BTPayPalSavedPaymentMethodRequest(amount: amount, currencyCode: "USD", merchantAccountID: merchantAccountID)
    }

    private static func instrumentResponse(label: String = "Visa", lastDigits: String = "0199") -> BTJSON {
        BTJSON(
            value: [
                "data": [
                    "paypalFundingInstrumentDetails": [
                        "payer": NSNull(),
                        "paymentMethods": [["label": label, "lastDigits": lastDigits, "type": "CARD"]]
                    ]
                ]
            ] as [String: Any]
        )
    }

    private static func payerOnlyResponse(isEditable: Bool? = true) -> BTJSON {
        var payer: [String: Any] = ["email": "buyer@example.com"]
        payer["editable"] = isEditable
        return BTJSON(
            value: [
                "data": [
                    "paypalFundingInstrumentDetails": [
                        "payer": payer,
                        "paymentMethods": []
                    ]
                ]
            ] as [String: Any]
        )
    }

    /// `onAppear` and `requestChanged` kick off detached `Task`s, so give them a beat to settle.
    private func drainTasks() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    private static func creditMessagingResponse(clickURL: String, isEmbeddable: Bool) -> BTJSON {
        BTJSON(
            value: [
                "messages": [
                    [
                        "preferred_message": [
                            "content": [
                                "main_items": [["type": "TEXT", "text": "Or 4 interest-free payments."]],
                                "action_items": [
                                    [
                                        "type": "LINK",
                                        "text": "Learn more",
                                        "click_url": clickURL,
                                        "embeddable": isEmbeddable
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ] as [String: Any]
        )
    }

    /// Drives a real credit-messaging fetch so `creditMessage` and `learnMoreURL` are populated
    /// the same way they are in production.
    private func seedCreditMessage(
        on sut: BTPayPalSavedPaymentMethodViewModel,
        clickURL: String,
        isEmbeddable: Bool
    ) async {
        mockAPIClient.cannedResponseBody = Self.creditMessagingResponse(clickURL: clickURL, isEmbeddable: isEmbeddable)
        sut.requestChanged(makeRequest(), showCreditMessaging: true)
        await drainTasks()
    }

    // MARK: - Initial state

    func testInit_startsInTheLoadingStateWithCreditMessagingShown() {
        let sut = makeSUT()

        XCTAssertEqual(sut.fiState, .loading)
        XCTAssertTrue(sut.showsCreditMessaging)
    }

    // MARK: - onAppear

    func testOnAppear_whenAnInstrumentIsReturned_movesToTheInstrumentState() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(merchantAccountID: "fake-merchant-account-id"), showCreditMessaging: false)
        await drainTasks()

        guard case .instrument(let summary) = sut.fiState else {
            return XCTFail("Expected .instrument, got \(sut.fiState)")
        }
        XCTAssertEqual(summary.label, "Visa")
        XCTAssertEqual(summary.lastDigits, "0199")
        XCTAssertTrue(sut.showsCreditMessaging)
        let input = (mockAPIClient.lastPOSTParameters?["variables"] as? [String: Any])?["input"] as? [String: Any]
        XCTAssertEqual(input?["merchantAccountId"] as? String, "fake-merchant-account-id")
    }

    /// A failed fetch must never block checkout, so the brand mark stays. The Pay Later offer is quoted
    /// against the funding instrument, so it must not survive, even if its response already landed.
    func testShowsCreditMessaging_whenCreditMessagingResolvesBeforeTheFIFetchFails_staysHidden() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)
        XCTAssertNotNil(sut.creditMessage)

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await drainTasks()

        XCTAssertEqual(sut.fiState, .brandOnly)
        XCTAssertFalse(sut.showsCreditMessaging)
    }

    /// An empty `paymentMethods` alongside an editable payer is a successful fetch, not a failure,
    /// so the Pay Later row still applies.
    func testOnAppear_whenAnEditablePayerIsReturned_keepsCreditMessaging() async {
        mockAPIClient.cannedResponseBody = Self.payerOnlyResponse()
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: true)
        await drainTasks()

        XCTAssertEqual(sut.fiState, .displayOnly(email: "buyer@example.com", isEditable: true))
        XCTAssertTrue(sut.showsCreditMessaging)
    }

    /// A payer who cannot change the funding instrument cannot act on the offer, so it is hidden along
    /// with the edit pencil. A missing `editable` is treated as not editable.
    func testOnAppear_whenThePayerIsNotEditable_hidesCreditMessaging() async {
        mockAPIClient.cannedResponseBody = Self.payerOnlyResponse(isEditable: nil)
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await drainTasks()

        XCTAssertEqual(sut.fiState, .displayOnly(email: "buyer@example.com", isEditable: false))
        XCTAssertFalse(sut.showsCreditMessaging)
    }

    func testOnAppear_whenCreditMessagingIsDisabled_doesNotFetchIt() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await drainTasks()

        XCTAssertNotEqual(mockAPIClient.lastPOSTPath, "/v2/credit/fetch-presentment-messages")
        XCTAssertNil(sut.creditMessage)
    }

    // MARK: - requestChanged

    /// `@StateObject` keeps one view model for the screen's life, so a changed amount has to be
    /// re-read at call time rather than captured once.
    func testRequestChanged_refetchesCreditMessagingWithTheNewAmount() async {
        let sut = makeSUT()

        sut.requestChanged(makeRequest(amount: "70.00"), showCreditMessaging: true)
        await drainTasks()

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v2/credit/fetch-presentment-messages")
        let placement = (mockAPIClient.lastPOSTParameters?["message_placements"] as? [[String: Any]])?.first
        let amount = placement?["amount"] as? [String: Any]
        XCTAssertEqual(amount?["value"] as? String, "70.00")
    }

    func testRequestChanged_whenCreditMessagingIsDisabled_doesNotFetch() async {
        let sut = makeSUT()

        sut.requestChanged(makeRequest(), showCreditMessaging: false)
        await drainTasks()

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
    }

    // MARK: - appReturnedToForeground

    /// An abandoned app switch never resumes the continuation, so foregrounding is the only
    /// signal that lets us take the full-screen loader down.
    func testAppReturnedToForeground_whileEditing_clearsTheLoaderAndRestoresThePriorState() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await drainTasks()
        let stateBeforeEdit = sut.fiState

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        XCTAssertTrue(sut.isEditing)

        sut.appReturnedToForeground()

        XCTAssertFalse(sut.isEditing)
        XCTAssertEqual(sut.fiState, stateBeforeEdit)
    }

    func testAppReturnedToForeground_whenNotEditing_isANoOp() {
        let sut = makeSUT()

        sut.appReturnedToForeground()

        XCTAssertFalse(sut.isEditing)
        XCTAssertEqual(sut.fiState, .loading)
    }

    // MARK: - editTapped

    func testEditTapped_whileAnEditIsAlreadyInFlight_isIgnored() {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "1")

        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())
        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())

        XCTAssertTrue(sut.isEditing)
    }

    // MARK: - Edit result delivery

    private func injectPayPalClient(nonce: String? = nil, orderID: String? = nil, error: Error? = nil) throws {
        let mockPayPalClient = MockPayPalClient(authorization: clientToken)
        mockPayPalClient.cannedNonce = try nonce.map {
            var details: [String: Any] = [:]
            details["paymentToken"] = orderID
            return try XCTUnwrap(BTPayPalAccountNonce(json: BTJSON(value: ["nonce": $0, "details": details])))
        }
        mockPayPalClient.cannedError = error
        fetchClient.payPalClient = mockPayPalClient
    }

    /// The merchant may present their own modal from `completion`, which iOS drops while ours is still up.
    func testEdit_whileTheLoaderIsOnScreen_deliversTheNonceOnlyAfterItDismisses() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        sut.editLoaderDidAppear()
        await drainTasks()

        XCTAssertFalse(sut.isEditing)
        XCTAssertNil(receivedNonce)

        sut.editLoaderDidDismiss()

        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    func testEdit_whenTokenizeFails_holdsTheErrorUntilTheLoaderDismisses() async throws {
        let cannedError = NSError(domain: "com.example.error", code: 1)
        try injectPayPalClient(error: cannedError)
        var receivedError: Error?
        let sut = makeSUT { _, error in receivedError = error }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        sut.editLoaderDidAppear()
        await drainTasks()

        XCTAssertFalse(sut.isEditing)
        XCTAssertNil(receivedError)

        sut.editLoaderDidDismiss()

        XCTAssertEqual(receivedError as NSError?, cannedError)
    }

    /// On the app-switch rail the loader is cleared on foreground, so there is no dismissal to wait for.
    func testEdit_whenTheLoaderIsAlreadyGone_deliversTheNonceImmediately() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await drainTasks()

        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    // MARK: - Refetch after edit

    func testEdit_whenItSucceeds_refetchesTheFIForTheApprovedOrderAndShowsIt() async throws {
        try injectPayPalClient(nonce: "fake-nonce", orderID: "fake-order-id")
        mockAPIClient.cannedResponseBody = Self.instrumentResponse(label: "Mastercard", lastDigits: "4444")
        let sut = makeSUT()

        sut.editTapped(
            checkoutRequest: BTPayPalCheckoutRequest(amount: "1"),
            request: makeRequest(merchantAccountID: "fake-merchant-account-id")
        )
        await drainTasks()

        let parameters = try XCTUnwrap(mockAPIClient.lastPOSTParameters)
        let input = try XCTUnwrap((parameters["variables"] as? [String: Any])?["input"] as? [String: Any])
        XCTAssertEqual(input["fundingInstrumentType"] as? String, "FI_FROM_APPROVED_CHECKOUT")
        XCTAssertEqual(input["orderId"] as? String, "fake-order-id")
        XCTAssertEqual(input["merchantAccountId"] as? String, "fake-merchant-account-id")

        guard case .instrument(let summary) = sut.fiState else {
            return XCTFail("Expected .instrument, got \(sut.fiState)")
        }
        XCTAssertEqual(summary.label, "Mastercard")
        XCTAssertEqual(summary.lastDigits, "4444")
    }

    /// The pre-edit instrument will no longer be charged, so it must not be shown again.
    func testEdit_whenTheRefetchFails_hidesTheRowButStillDeliversTheNonce() async throws {
        try injectPayPalClient(nonce: "fake-nonce", orderID: "fake-order-id")
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await drainTasks()
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await drainTasks()

        XCTAssertEqual(sut.fiState, .hidden)
        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    // MARK: - learnMoreTapped

    func testLearnMoreTapped_whenTheMessageIsEmbeddable_presentsTheInAppLander() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)

        sut.learnMoreTapped()

        XCTAssertTrue(sut.isLanderPresented)
        XCTAssertNil(urlOpener.openedURL)
    }

    func testLearnMoreTapped_whenTheMessageIsNotEmbeddable_opensExternally() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: false)

        sut.learnMoreTapped()

        XCTAssertFalse(sut.isLanderPresented)
        XCTAssertEqual(urlOpener.openedURL?.absoluteString, "https://example.com/lander")
    }

    /// `SFSafariViewController` only loads web URLs, so anything else must be dropped rather than opened.
    func testLearnMoreTapped_whenTheSchemeIsNotWeb_doesNothing() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "javascript:alert(1)", isEmbeddable: true)

        sut.learnMoreTapped()

        XCTAssertFalse(sut.isLanderPresented)
        XCTAssertNil(urlOpener.openedURL)
    }

    func testLearnMoreTapped_whenThereIsNoURL_doesNothing() {
        let sut = makeSUT()

        sut.learnMoreTapped()

        XCTAssertFalse(sut.isLanderPresented)
        XCTAssertNil(urlOpener.openedURL)
    }

    // MARK: - state(from:)

    /// The instrument wins over the payer, so a buyer never sees their email when a card is known.
    func testStateFromSummary_whenBothAredPresent_prefersTheFundingInstrument() throws {
        let summary = try XCTUnwrap(
            BTPayPalSavedPaymentMethodSummary(
                json: BTJSON(
                    value: [
                        "payer": ["email": "buyer@example.com", "editable": true],
                        "paymentMethods": [["label": "Visa", "type": "CARD"]]
                    ] as [String: Any]
                )
            )
        )

        guard case .instrument = BTPayPalSavedPaymentMethodViewModel.state(from: summary) else {
            return XCTFail("Expected .instrument")
        }
    }

    func testStateFromSummary_whenNeitherIsPresent_hidesTheComponent() throws {
        let summary = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: BTJSON(value: [:] as [String: Any])))

        XCTAssertEqual(BTPayPalSavedPaymentMethodViewModel.state(from: summary), .hidden)
    }

    // MARK: - Refetch guard

    /// `onAppear` refires on tab switches, and a refetch would bring back the pre-edit instrument.
    func testOnAppear_afterAnEdit_doesNotRefetch() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        let sut = makeSUT()
        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await drainTasks()
        XCTAssertTrue(sut.didCompleteEdit)
        mockAPIClient.lastPOSTParameters = nil

        sut.onAppear(request: makeRequest(), showCreditMessaging: true)
        await drainTasks()

        XCTAssertNil(mockAPIClient.lastPOSTParameters)
    }
}

// MARK: - Test doubles

private final class MockURLOpener: URLOpener {

    private(set) var openedURL: URL?

    func canOpenURL(_ url: URL) -> Bool { true }

    func isPayPalAppInstalled() -> Bool { false }

    func isVenmoAppInstalled() -> Bool { false }

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
    ) {
        openedURL = url
    }
}
