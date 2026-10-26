import XCTest
import CardinalMobile
@testable import BraintreeCore
@testable import BraintreePaymentActions

class BTPaymentActionThreeDSecureProvider_Tests: XCTestCase {

    var mockCardinalSession: MockCardinalSession!
    var configuration: BTConfiguration!

    override func setUp() {
        super.setUp()
        mockCardinalSession = MockCardinalSession()
        configuration = BTConfiguration(json: BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "fake-cardinal-authentication-jwt"]
        ]))
    }

    private func makeSut(
        isApplicationActive: Bool = true,
        challengeWatchdogTimeoutNanoseconds: UInt64 = 60_000_000_000
    ) throws -> BTPaymentActionThreeDSecureProvider {
        try BTPaymentActionThreeDSecureProvider(
            configuration: configuration,
            cardinalSession: mockCardinalSession,
            applicationStateProvider: StubApplicationStateProvider(isApplicationActive: isApplicationActive),
            challengeWatchdogTimeoutNanoseconds: challengeWatchdogTimeoutNanoseconds
        )
    }

    // MARK: - init(configuration:)

    func testInit_missingCardinalAuthenticationJWT_throws() {
        let configurationWithoutJWT = BTConfiguration(json: BTJSON(value: [:] as [String: Any]))

        XCTAssertThrowsError(
            try BTPaymentActionThreeDSecureProvider(configuration: configurationWithoutJWT, cardinalSession: mockCardinalSession)
        ) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .missingCardinalAuthenticationJWT)
        }
    }

    // MARK: - collectDeviceData()

    func testCollectDeviceData_returnsDfReferenceID() async throws {
        mockCardinalSession.dfReferenceID = "df-reference-123"
        let sut = try makeSut()

        let dfReferenceID = try await sut.collectDeviceData()

        XCTAssertEqual(dfReferenceID, "df-reference-123")
    }

    func testCollectDeviceData_calledWhileInFlight_throwsAlreadyInProgress() async throws {
        let sut = try makeSut()
        sut.state = .collectingDeviceData

        do {
            _ = try await sut.collectDeviceData()
            XCTFail("Expected cardinalInteractionAlreadyInProgress to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .cardinalInteractionAlreadyInProgress)
        }
    }

    // MARK: - presentChallenge(transactionID:payload:) - Foreground gate

    func testPresentChallenge_appNotActive_throwsForegroundRequired() async throws {
        let sut = try makeSut(isApplicationActive: false)

        do {
            _ = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")
            XCTFail("Expected foregroundRequired to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .foregroundRequired)
        }
    }

    func testPresentChallenge_calledWhileInFlight_throwsAlreadyInProgress() async throws {
        let sut = try makeSut()
        sut.state = .presentingChallenge

        do {
            _ = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")
            XCTFail("Expected cardinalInteractionAlreadyInProgress to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .cardinalInteractionAlreadyInProgress)
        }
    }

    // MARK: - presentChallenge(transactionID:payload:) - Watchdog

    func testPresentChallenge_cardinalNeverCallsBack_timesOutViaWatchdog() async throws {
        let sut = try makeSut(challengeWatchdogTimeoutNanoseconds: 1_000_000)
        mockCardinalSession.actionCodeToDeliver = nil

        do {
            _ = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")
            XCTFail("Expected cardinalChallengeTimedOut to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .cardinalChallengeTimedOut)
        }
    }

    // MARK: - resolveChallenge(actionCode:serverJWT:) - Complete action-code mapping

    func testResolveChallenge_success_resolvesValidated() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .success
        mockCardinalSession.serverJWTToDeliver = "server-jwt-success"

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")

        XCTAssertEqual(outcome, .validated(serverJWT: "server-jwt-success"))
    }

    func testResolveChallenge_noAction_resolvesValidated() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .noAction

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")

        if case .validated = outcome {
            // expected
        } else {
            XCTFail("Expected .validated, got \(outcome)")
        }
    }

    func testResolveChallenge_failure_resolvesValidated() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .failure

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")

        if case .validated = outcome {
            // expected
        } else {
            XCTFail("Expected .validated, got \(outcome)")
        }
    }

    func testResolveChallenge_cancel_resolvesAbandoned() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .cancel

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")

        XCTAssertEqual(outcome, .abandoned)
    }

    func testResolveChallenge_timeout_resolvesAbandoned() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .timeout

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")

        XCTAssertEqual(outcome, .abandoned)
    }

    func testResolveChallenge_error_throwsCardinalChallengeFailed() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .error

        do {
            _ = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")
            XCTFail("Expected cardinalChallengeFailed to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .cardinalChallengeFailed)
        }
    }

    // MARK: - resolveChallenge(actionCode:serverJWT:) - Re-entry safety

    func testResolveChallenge_calledTwice_secondCallIsNoOp() async throws {
        let sut = try makeSut()
        mockCardinalSession.actionCodeToDeliver = .success

        let outcome = try await sut.presentChallenge(transactionID: "txn-1", payload: "payload")
        XCTAssertEqual(outcome, .validated(serverJWT: "fake-server-jwt"))

        // The continuation was already consumed; a second resolve call (e.g. a duplicate delegate
        // callback) must not crash or resume anything a second time.
        sut.resolveChallenge(actionCode: .success, serverJWT: "late-jwt")
    }
}

/// A seam-only stub — doesn't need to be a mock class with call tracking, just a fixed value.
private struct StubApplicationStateProvider: ApplicationStateProviding {
    let isApplicationActive: Bool
}
