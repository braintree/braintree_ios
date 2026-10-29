import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreePayPal
@testable import BraintreePayPalSavedPaymentMethod

@MainActor
final class PayPalSavedPaymentMethodViewModel_Tests: XCTestCase {

    // MARK: - Properties

    private let clientToken = TestClientTokenFactory.token(
        withVersion: 3,
        overrides: ["paymentMethodIdJwt": "fake-payment-method-id-jwt"]
    )
    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://example.com/universal-link")!

    private var mockAPIClient: MockAPIClient!
    private var fetchClient: PayPalSavedPaymentMethodClient!
    private var fakeApplication: FakeApplication!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        fetchClient = PayPalSavedPaymentMethodClient(authorization: clientToken, universalLink: universalLink)
        fetchClient.apiClient = mockAPIClient
        fakeApplication = FakeApplication()
    }

    override func tearDown() {
        mockAPIClient = nil
        fetchClient = nil
        fakeApplication = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }
    ) -> PayPalSavedPaymentMethodViewModel {
        let sut = PayPalSavedPaymentMethodViewModel(fetchClient: fetchClient, completion: completion)
        sut.application = fakeApplication
        return sut
    }

    private func makeRequest(amount: String = "55.00", merchantAccountID: String? = nil) -> PayPalSavedPaymentMethodRequest {
        PayPalSavedPaymentMethodRequest(amount: amount, currencyCode: "USD", merchantAccountID: merchantAccountID)
    }

    private static func instrumentResponse(label: String = "Visa", lastDigits: String = "0199") -> BTJSON {
        BTJSON(
            value: [
                "data": [
                    "paypalFundingInstrumentDetails": [
                        "payer": NSNull(),
                        "paymentMethods": [
                            ["id": "CC-123", "label": label, "lastDigits": lastDigits, "type": "CARD", "cardBrand": "VISA"]
                        ]
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

    /// Awaits the tasks the view model has started. The edit starts the post-edit refetch, so it is awaited last.
    private func settle(_ sut: PayPalSavedPaymentMethodViewModel) async {
        await sut.fiFetchTask?.value
        await sut.creditTask?.value
        await sut.editTask?.value
        await sut.fiRefetchTask?.value
    }

    private static func creditMessagingResponse(clickURL: String, isEmbeddable: Bool) -> BTJSON {
        BTJSON(
            value: [
                "messages": [
                    [
                        "preferred_message": [
                            "type": "PLST_SQ",
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

    /// Drives a real credit-messaging fetch so `creditMessage` and its "Learn more" link are populated
    /// the same way they are in production.
    private func seedCreditMessage(
        on sut: PayPalSavedPaymentMethodViewModel,
        clickURL: String,
        isEmbeddable: Bool
    ) async {
        mockAPIClient.cannedResponseBody = Self.creditMessagingResponse(clickURL: clickURL, isEmbeddable: isEmbeddable)
        sut.requestChanged(makeRequest(), showCreditMessaging: true)
        await settle(sut)
    }

    @discardableResult
    private func injectPayPalClient(
        nonce: String? = nil,
        orderID: String? = nil,
        error: Error? = nil
    ) throws -> MockPayPalClient {
        let mockPayPalClient = MockPayPalClient(authorization: clientToken)
        mockPayPalClient.cannedNonce = try nonce.map {
            var details: [String: Any] = [:]
            details["paymentToken"] = orderID
            return try XCTUnwrap(BTPayPalAccountNonce(json: BTJSON(value: ["nonce": $0, "details": details])))
        }
        mockPayPalClient.cannedError = error
        fetchClient.payPalClient = mockPayPalClient
        return mockPayPalClient
    }

    private static func creditAmount(in parameters: [String: Any]?) -> String? {
        let placement = (parameters?["message_placements"] as? [[String: Any]])?.first
        return (placement?["amount"] as? [String: Any])?["value"] as? String
    }

    private static func orderID(in parameters: [String: Any]?) -> String? {
        ((parameters?["variables"] as? [String: Any])?["input"] as? [String: Any])?["orderId"] as? String
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
        await settle(sut)

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
        await settle(sut)

        XCTAssertEqual(sut.fiState, .brandOnly)
        XCTAssertFalse(sut.showsCreditMessaging)
    }

    /// An empty `paymentMethods` alongside an editable payer is a successful fetch, not a failure,
    /// so the Pay Later row still applies.
    func testOnAppear_whenAnEditablePayerIsReturned_keepsCreditMessaging() async {
        mockAPIClient.cannedResponseBody = Self.payerOnlyResponse()
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: true)
        await settle(sut)

        XCTAssertEqual(sut.fiState, .displayOnly(email: "buyer@example.com", isEditable: true))
        XCTAssertTrue(sut.showsCreditMessaging)
    }

    /// A payer who cannot change the funding instrument cannot act on the offer, so it is hidden along
    /// with the edit pencil. A missing `editable` is treated as not editable.
    func testOnAppear_whenThePayerIsNotEditable_hidesCreditMessaging() async {
        mockAPIClient.cannedResponseBody = Self.payerOnlyResponse(isEditable: nil)
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        XCTAssertEqual(sut.fiState, .displayOnly(email: "buyer@example.com", isEditable: false))
        XCTAssertFalse(sut.showsCreditMessaging)
    }

    func testOnAppear_whenCreditMessagingIsDisabled_doesNotFetchIt() async {
        mockAPIClient.cannedResponseBody = Self.creditMessagingResponse(clickURL: "https://example.com/lander", isEmbeddable: true)
        let sut = makeSUT()

        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        XCTAssertNil(sut.creditMessage)
    }

    /// A tab switch refires `onAppear`; a failed refetch then must not replace the FI already shown.
    func testOnAppear_whenARefetchFails_keepsTheFIAlreadyShown() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)
        let shownState = sut.fiState

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        XCTAssertEqual(sut.fiState, shownState)
        XCTAssertTrue(sut.showsCreditMessaging)
    }

    /// A failed refresh for the same amount keeps the message shown; a new amount must not keep a stale quote.
    func testCreditRefetchFailure_keepsTheMessageForTheSameRequestButClearsItForANewAmount() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)
        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)

        sut.requestChanged(makeRequest(), showCreditMessaging: true)
        await settle(sut)
        XCTAssertNotNil(sut.creditMessage)

        sut.requestChanged(makeRequest(amount: "70.00"), showCreditMessaging: true)
        await settle(sut)
        XCTAssertNil(sut.creditMessage)
    }

    /// `onAppear` refires on tab switches, and a refetch would bring back the pre-edit instrument.
    func testOnAppear_afterAnEdit_doesNotRefetch() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        let sut = makeSUT()
        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await settle(sut)
        XCTAssertTrue(sut.didCompleteEdit)
        mockAPIClient.lastPOSTParameters = nil

        sut.onAppear(request: makeRequest(), showCreditMessaging: true)
        await settle(sut)

        XCTAssertNil(mockAPIClient.lastPOSTParameters)
    }

    // MARK: - requestChanged

    /// `@StateObject` keeps one view model for the screen's life, so a changed amount has to be
    /// re-read at call time rather than captured once.
    func testRequestChanged_refetchesCreditMessagingWithTheNewAmount() async {
        let sut = makeSUT()

        sut.requestChanged(makeRequest(amount: "70.00"), showCreditMessaging: true)
        await settle(sut)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v2/credit/fetch-presentment-messages")
        let placement = (mockAPIClient.lastPOSTParameters?["message_placements"] as? [[String: Any]])?.first
        let amount = placement?["amount"] as? [String: Any]
        XCTAssertEqual(amount?["value"] as? String, "70.00")
    }

    func testRequestChanged_whenCreditMessagingIsDisabled_doesNotFetch() async {
        let sut = makeSUT()

        sut.requestChanged(makeRequest(), showCreditMessaging: false)
        await settle(sut)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
    }

    func testRequestChanged_whenTheOlderAmountRespondsLast_keepsTheNewerMessage() async throws {
        let apiClient = GatedAPIClient(authorization: clientToken) { parameters in
            let placement = (parameters?["message_placements"] as? [[String: Any]])?.first
            let amount = (placement?["amount"] as? [String: Any])?["value"] as? String ?? ""
            let message: [String: Any] = ["main_items": [["type": "TEXT", "text": "Pay in 4 on \(amount)"]]]
            return BTJSON(value: ["messages": [["preferred_message": ["content": message]]]] as [String: Any])
        }
        fetchClient.apiClient = apiClient
        let sut = makeSUT()

        sut.requestChanged(makeRequest(amount: "50.00"), showCreditMessaging: true)
        let olderFetch = sut.creditTask
        sut.requestChanged(makeRequest(amount: "70.00"), showCreditMessaging: true)
        await apiClient.waitUntilHolding(2)

        apiClient.release { Self.creditAmount(in: $0) == "70.00" }
        await sut.creditTask?.value
        apiClient.release { Self.creditAmount(in: $0) == "50.00" }
        await olderFetch?.value

        XCTAssertEqual(sut.creditMessage?.message, "Pay in 4 on 70.00")
    }

    // MARK: - appReturnedToForeground

    /// An abandoned app switch never resumes the continuation, so foregrounding is the only
    /// signal that lets us take the full-screen loader down.
    func testAppReturnedToForeground_whileEditing_clearsTheLoader() async throws {
        try injectPayPalClient()
        let sut = makeSUT()

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        XCTAssertTrue(sut.isEditing)

        sut.appReturnedToForeground()

        XCTAssertFalse(sut.isEditing)
    }

    // MARK: - editTapped

    func testEditTapped_whileAnEditIsAlreadyInFlight_isIgnored() async throws {
        let mockPayPalClient = try injectPayPalClient(nonce: "fake-nonce")
        let sut = makeSUT()
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "1")

        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())
        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())
        await settle(sut)

        XCTAssertEqual(mockPayPalClient.tokenizeCallCount, 1)
    }

    func testEditTapped_whileTheLoaderIsDismissing_isIgnored() async throws {
        let mockPayPalClient = try injectPayPalClient(nonce: "fake-nonce")
        let sut = makeSUT()
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "1")

        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())
        sut.editLoaderDidAppear()
        sut.appReturnedToForeground()
        sut.editTapped(checkoutRequest: checkoutRequest, request: makeRequest())
        await settle(sut)

        XCTAssertEqual(mockPayPalClient.tokenizeCallCount, 1)
    }

    // MARK: - Edit result delivery

    /// A fast failure (e.g. the missing-JWT check) can land before the loader appears. A loader taken
    /// down before it presents never reports a dismissal, so it stays up until it appears.
    func testEdit_whenTokenizeFailsBeforeTheLoaderAppears_deliversTheErrorAfterItAppearsAndDismisses() async throws {
        let cannedError = NSError(domain: "com.example.error", code: 1)
        try injectPayPalClient(error: cannedError)
        var receivedError: Error?
        let sut = makeSUT { _, error in receivedError = error }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await settle(sut)

        XCTAssertTrue(sut.isEditing)
        XCTAssertNil(receivedError)

        sut.editLoaderDidAppear()

        XCTAssertFalse(sut.isEditing)
        XCTAssertNil(receivedError)

        sut.editLoaderDidDismiss()

        XCTAssertEqual(receivedError as NSError?, cannedError)
    }

    /// On the app-switch rail the loader is dismissed on foreground, before the nonce arrives.
    func testEdit_whenTheLoaderIsAlreadyGone_deliversTheNonceImmediately() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        sut.editLoaderDidAppear()
        sut.appReturnedToForeground()
        sut.editLoaderDidDismiss()
        await settle(sut)

        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    /// Foregrounding starts the dismissal, and the nonce usually lands before it finishes.
    func testEdit_whenTheNonceArrivesWhileTheLoaderIsDismissing_deliversItOnDismiss() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        sut.editLoaderDidAppear()
        sut.appReturnedToForeground()
        await settle(sut)

        XCTAssertFalse(sut.isEditing)
        XCTAssertNil(receivedNonce)

        sut.editLoaderDidDismiss()

        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    // MARK: - Refetch after edit

    func testEdit_whenItSucceeds_refetchesTheFIForTheApprovedOrderAndShowsIt() async throws {
        try injectPayPalClient(nonce: "fake-nonce", orderID: "fake-order-id")
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)
        mockAPIClient.cannedResponseBody = Self.instrumentResponse(label: "Mastercard", lastDigits: "4444")

        sut.editTapped(
            checkoutRequest: BTPayPalCheckoutRequest(amount: "1"),
            request: makeRequest(merchantAccountID: "fake-merchant-account-id")
        )
        await settle(sut)

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
        XCTAssertNil(sut.creditMessage)
        XCTAssertFalse(sut.showsCreditMessaging)
    }

    /// The pre-edit instrument will no longer be charged, so only the brand mark is shown.
    func testEdit_whenTheRefetchFails_showsTheBrandMarkAndStillDeliversTheNonce() async throws {
        try injectPayPalClient(nonce: "fake-nonce", orderID: "fake-order-id")
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        var receivedNonce: BTPayPalAccountNonce?
        let sut = makeSUT { nonce, _ in receivedNonce = nonce }
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await settle(sut)
        sut.editLoaderDidDismiss()

        XCTAssertEqual(sut.fiState, .brandOnly)
        XCTAssertFalse(sut.showsCreditMessaging)
        XCTAssertEqual(receivedNonce?.nonce, "fake-nonce")
    }

    func testEdit_whenAnEarlierEditsRefetchRespondsLast_keepsTheLatestFI() async throws {
        let apiClient = GatedAPIClient(authorization: clientToken) { parameters in
            let details: [String: Any] = [
                "paymentMethods": [["label": Self.orderID(in: parameters) ?? "", "lastDigits": "0199", "type": "CARD"]]
            ]
            return BTJSON(value: ["data": ["paypalFundingInstrumentDetails": details]] as [String: Any])
        }
        fetchClient.apiClient = apiClient
        let sut = makeSUT()

        try injectPayPalClient(nonce: "first-nonce", orderID: "first-order")
        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await sut.editTask?.value
        let olderRefetch = sut.fiRefetchTask
        sut.editLoaderDidAppear()
        sut.editLoaderDidDismiss()

        try injectPayPalClient(nonce: "second-nonce", orderID: "second-order")
        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await sut.editTask?.value
        await apiClient.waitUntilHolding(2)

        apiClient.release { Self.orderID(in: $0) == "second-order" }
        await sut.fiRefetchTask?.value
        apiClient.release { Self.orderID(in: $0) == "first-order" }
        await olderRefetch?.value

        guard case .instrument(let summary) = sut.fiState else {
            return XCTFail("Expected .instrument, got \(sut.fiState)")
        }
        XCTAssertEqual(summary.label, "second-order")
    }

    // MARK: - learnMoreTapped

    func testLearnMoreTapped_whenTheMessageIsEmbeddable_presentsTheInAppLander() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)

        sut.learnMoreTapped()

        XCTAssertEqual(sut.presentedLander?.url.absoluteString, "https://example.com/lander")
        XCTAssertNil(fakeApplication.lastOpenURL)
    }

    /// The credit message can be cleared while the lander is open (e.g. a failed fetch for a new amount).
    func testLearnMoreTapped_whenTheMessageIsClearedWhileOpen_keepsTheLanderURL() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)
        sut.learnMoreTapped()

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)
        sut.requestChanged(makeRequest(amount: "70.00"), showCreditMessaging: true)
        await settle(sut)

        XCTAssertNil(sut.creditMessage)
        XCTAssertEqual(sut.presentedLander?.url.absoluteString, "https://example.com/lander")
    }

    func testLearnMoreTapped_whenTheMessageIsNotEmbeddable_opensExternally() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: false)

        sut.learnMoreTapped()

        XCTAssertNil(sut.presentedLander)
        XCTAssertEqual(fakeApplication.lastOpenURL?.absoluteString, "https://example.com/lander")
    }

    /// `SFSafariViewController` only loads web URLs, so anything else must be dropped rather than opened.
    func testLearnMoreTapped_whenTheSchemeIsNotWeb_doesNothing() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "javascript:alert(1)", isEmbeddable: true)

        sut.learnMoreTapped()

        XCTAssertNil(sut.presentedLander)
        XCTAssertNil(fakeApplication.lastOpenURL)
    }

    // MARK: - Analytics

    func testEditTapped_sendsEditSelectedEventWithTheFIType() async throws {
        try injectPayPalClient(nonce: "fake-nonce")
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, PayPalSavedPaymentMethodAnalytics.editSelected)
        XCTAssertEqual(mockAPIClient.postedFIType, "CARD")
        XCTAssertEqual(mockAPIClient.postedFIBrand, "VISA")
    }

    func testLearnMoreTapped_sendsLearnMoreSelectedEventWithTheMessageType() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)

        sut.learnMoreTapped()

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, PayPalSavedPaymentMethodAnalytics.creditMessagingLearnMoreSelected)
        XCTAssertEqual(mockAPIClient.postedMessageType, "PLST_SQ")
    }

    func testFIDidRender_afterTheInitialFetch_sendsRenderSucceededEventForTheStickyFI() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        sut.fiDidRender(style: PayPalSavedPaymentMethodViewStyle(showPayPalLabel: false))

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, PayPalSavedPaymentMethodAnalytics.renderSucceeded)
        XCTAssertEqual(mockAPIClient.postedRenderTrigger, "sticky_fi")
        XCTAssertEqual(mockAPIClient.postedShownContent, "funding_instrument")
        XCTAssertEqual(mockAPIClient.postedFIType, "CARD")
        XCTAssertEqual(mockAPIClient.postedFIBrand, "VISA")
        XCTAssertEqual(mockAPIClient.postedFIID, "CC-123")
        XCTAssertEqual(mockAPIClient.postedRenderedEditTag, true)
        XCTAssertEqual(mockAPIClient.postedRenderedLogo, true)
        XCTAssertEqual(mockAPIClient.postedRenderedLabel, false)
        XCTAssertEqual(mockAPIClient.postedRenderedMessageSlot, true)
        XCTAssertNil(mockAPIClient.postedContextID)
    }

    func testFIDidRender_afterAnEdit_sendsRenderSucceededEventWithTheApprovedOrderID() async throws {
        try injectPayPalClient(nonce: "fake-nonce", orderID: "fake-order-id")
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()

        sut.editTapped(checkoutRequest: BTPayPalCheckoutRequest(amount: "1"), request: makeRequest())
        await settle(sut)
        sut.fiDidRender(style: PayPalSavedPaymentMethodViewStyle())

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, PayPalSavedPaymentMethodAnalytics.renderSucceeded)
        XCTAssertEqual(mockAPIClient.postedRenderTrigger, "fi_from_approved_checkout")
        XCTAssertEqual(mockAPIClient.postedContextID, "fake-order-id")
    }

    func testFIDidRender_whenOnlyTheBrandMarkIsLeftAndItIsHidden_sendsHiddenContent() async {
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)

        sut.fiDidRender(style: PayPalSavedPaymentMethodViewStyle(showPayPalLogo: false, showPayPalLabel: false))

        XCTAssertEqual(mockAPIClient.postedShownContent, "hidden")
        XCTAssertEqual(mockAPIClient.postedRenderedEditTag, false)
    }

    func testFIDidRender_whileLoading_sendsNoEvent() {
        let sut = makeSUT()

        sut.fiDidRender(style: PayPalSavedPaymentMethodViewStyle())

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.isEmpty)
    }

    func testCreditMessageDidRender_whenAMessageIsShown_sendsRenderSucceededEventWithTheMessageType() async {
        mockAPIClient.cannedResponseBody = Self.instrumentResponse()
        let sut = makeSUT()
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)

        sut.creditMessageDidRender()

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, PayPalSavedPaymentMethodAnalytics.creditMessagingRenderSucceeded)
        XCTAssertEqual(mockAPIClient.postedMessageType, "PLST_SQ")
    }

    /// The message can land before the FI. It is held until the FI settles, and dropped if the FI ends up brand-only.
    func testVisibleCreditMessage_whenTheMessageArrivesBeforeTheFIFails_isNeverShownOrReported() async {
        let sut = makeSUT()
        await seedCreditMessage(on: sut, clickURL: "https://example.com/lander", isEmbeddable: true)

        XCTAssertNil(sut.visibleCreditMessage)

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "com.example.error", code: 1)
        sut.onAppear(request: makeRequest(), showCreditMessaging: false)
        await settle(sut)
        sut.creditMessageDidRender()

        XCTAssertNil(sut.visibleCreditMessage)
        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains(PayPalSavedPaymentMethodAnalytics.creditMessagingRenderSucceeded))
    }

    // MARK: - state(from:)

    /// The instrument wins over the payer, so a buyer never sees their email when a card is known.
    func testStateFromSummary_whenBothArePresent_prefersTheFundingInstrument() throws {
        let summary = try XCTUnwrap(
            PayPalSavedPaymentMethodSummary(
                json: BTJSON(
                    value: [
                        "payer": ["email": "buyer@example.com", "editable": true],
                        "paymentMethods": [["label": "Visa", "type": "CARD"]]
                    ] as [String: Any]
                )
            )
        )

        guard case .instrument = PayPalSavedPaymentMethodViewModel.state(from: summary) else {
            return XCTFail("Expected .instrument")
        }
    }

    func testStateFromSummary_whenNeitherIsPresent_showsTheBrandMark() throws {
        let summary = try XCTUnwrap(PayPalSavedPaymentMethodSummary(json: BTJSON(value: [:] as [String: Any])))

        XCTAssertEqual(PayPalSavedPaymentMethodViewModel.state(from: summary), .brandOnly)
    }
}

// MARK: - Test doubles

/// Holds every POST until the test releases it, so a test can choose the order responses land in without timing.
private final class GatedAPIClient: MockAPIClient {

    private let lock = NSLock()
    private let response: ([String: Any]?) -> BTJSON?
    private var held: [(parameters: [String: Any]?, continuation: CheckedContinuation<Void, Never>)] = []

    init(authorization: String, response: @escaping ([String: Any]?) -> BTJSON?) {
        self.response = response
        super.init(authorization: authorization)
    }

    override func post(
        _ path: String,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil,
        httpType: BTAPIClientHTTPService = .gateway
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        let dictionary = try parameters?.toDictionary()
        await withCheckedContinuation { continuation in
            lock.withLock { held.append((dictionary, continuation)) }
        }
        return (response(dictionary), nil)
    }

    /// Returns once `count` requests are in flight.
    func waitUntilHolding(_ count: Int) async {
        while lock.withLock({ held.count }) < count {
            await Task.yield()
        }
    }

    /// Lets the first held request matching `predicate` respond.
    func release(where predicate: ([String: Any]?) -> Bool) {
        let continuation = lock.withLock { () -> CheckedContinuation<Void, Never>? in
            guard let index = held.firstIndex(where: { predicate($0.parameters) }) else { return nil }
            return held.remove(at: index).continuation
        }
        continuation?.resume()
    }
}
