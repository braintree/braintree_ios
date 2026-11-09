import XCTest
@testable import BraintreeCore
@testable import BraintreePaymentActions

/// End-to-end 3D Secure journeys through the real `BTPaymentActionsClient` drive loop.
///
/// The Payment Actions server schema isn't deployed to sandbox yet, so the server is a
/// `FakePaymentActionsServer` and Cardinal is a `MockCardinalSession` — everything in between (config
/// fetch, request encoding, drive loop, analytics) is the real SDK.
class BTPaymentActionsThreeDSecure_IntegrationTests: XCTestCase {

    // MARK: - Properties

    private var fakeServer: FakePaymentActionsServer!
    private var mockCardinalSession: MockCardinalSession!
    private var cardRequest: BTCreditCard!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockCardinalSession = MockCardinalSession()
        cardRequest = BTCreditCard(
            cardNumber: "4000000000001091",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
    }

    override func tearDown() {
        fakeServer = nil
        super.tearDown()
    }

    // MARK: - AUTOMATIC Confirmation

    func testHandleNextAction_autoConfirmWithChallenge_completes() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .automatic, authentication: .challenge)
        let client = makeClient()

        let submitResult = try await client.submitForPaymentAction(cardRequest)
        XCTAssertEqual(submitResult.type, .customerActionRequired)

        let result = try await client.handleNextAction()

        XCTAssertEqual(result.type, .completed)
        XCTAssertEqual(fakeServer.completedActions, ["deviceDataCollection", "challenge"])
    }

    func testHandleNextAction_autoConfirmFrictionless_completesWithoutChallenge() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .automatic, authentication: .frictionless)
        let client = makeClient()

        _ = try await client.submitForPaymentAction(cardRequest)
        let result = try await client.handleNextAction()

        XCTAssertEqual(result.type, .completed)
        XCTAssertEqual(fakeServer.completedActions, ["deviceDataCollection"])
    }

    // MARK: - MANUAL Confirmation

    func testHandleNextAction_manualConfirmWithChallenge_confirmsThenCompletes() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .manual, authentication: .challenge)
        let client = makeClient()

        let submitResult = try await client.submitForPaymentAction(cardRequest)
        XCTAssertEqual((submitResult as? BTServerActionRequiredResult)?.serverAction, .confirm)

        // Re-entry after the merchant's out-of-band confirm picks up the new server state: the SDK runs
        // 3DS, and the server then asks for a second confirm (this time of the authenticated payment).
        fakeServer.confirm()
        let authenticatedResult = try await client.handleNextAction()
        XCTAssertEqual((authenticatedResult as? BTServerActionRequiredResult)?.serverAction, .confirm)
        XCTAssertEqual(fakeServer.completedActions, ["deviceDataCollection", "challenge"])

        fakeServer.confirm()
        let result = try await client.handleNextAction()
        XCTAssertEqual(result.type, .completed)
    }

    func testHandleNextAction_manualCapture_endsAtCaptureHandoff() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .automatic, capture: .manual, authentication: .challenge)
        let client = makeClient()

        _ = try await client.submitForPaymentAction(cardRequest)
        let result = try await client.handleNextAction()

        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .capture)
    }

    // MARK: - Abandoned Challenge

    func testHandleNextAction_challengeCanceled_returnsCanceledThenRetrySucceeds() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .automatic, authentication: .challenge)
        let client = makeClient()
        mockCardinalSession.actionCodeToDeliver = .cancel

        _ = try await client.submitForPaymentAction(cardRequest)
        let canceledResult = try await client.handleNextAction()
        XCTAssertEqual(canceledResult.type, .threeDSecureCanceled)

        // The Payment Action is still alive, so the shopper can retry.
        mockCardinalSession.actionCodeToDeliver = .success
        let retryResult = try await client.handleNextAction()
        XCTAssertEqual(retryResult.type, .completed)
    }

    // MARK: - Soft Decline
    //
    // These run against the fake server's assumed contract (`processing` then `requires_customer_action`);
    // The ADR is unmerged and nonce reuse is server-side, so re-verify against real sandbox once deployed.

    func testHandleNextAction_autoConfirmSoftDecline_authenticatesAndCompletes() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .automatic, authentication: .challenge, softDeclines: true)
        let client = makeClient()

        let submitResult = try await client.submitForPaymentAction(cardRequest)
        XCTAssertEqual(submitResult.type, .processing)

        let result = try await client.handleNextAction()

        XCTAssertEqual(result.type, .completed)
        XCTAssertEqual(fakeServer.completedActions, ["deviceDataCollection", "challenge"])
    }

    func testHandleNextAction_manualConfirmSoftDecline_authenticatesThenAwaitsSecondConfirm() async throws {
        fakeServer = FakePaymentActionsServer(confirmation: .manual, authentication: .challenge, softDeclines: true)
        let client = makeClient()

        _ = try await client.submitForPaymentAction(cardRequest)
        fakeServer.confirm()
        let authenticatedResult = try await client.handleNextAction()
        XCTAssertEqual((authenticatedResult as? BTServerActionRequiredResult)?.serverAction, .confirm)
        XCTAssertEqual(fakeServer.completedActions, ["deviceDataCollection", "challenge"])

        fakeServer.confirm()
        let result = try await client.handleNextAction()
        XCTAssertEqual(result.type, .completed)
    }

    // MARK: - Blocked On Server Work

    func testHandleNextAction_appTerminatedDuringChallenge_recoversAfterRelaunch() throws {
        throw XCTSkip("Blocked: needs a real server-side Payment Action to survive a process restart")
    }

    func testHandleNextAction_concurrentPaymentActions_signalUnderOwnAuthorization() throws {
        throw XCTSkip("Blocked: needs two real server-side Payment Actions with distinct client tokens")
    }

    // MARK: - Helpers

    private func makeClient() -> BTPaymentActionsClient {
        let client = BTPaymentActionsClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        client.cardinalSession = mockCardinalSession
        client.applicationStateProvider = ActiveApplicationStateProvider()
        return client
    }
}
