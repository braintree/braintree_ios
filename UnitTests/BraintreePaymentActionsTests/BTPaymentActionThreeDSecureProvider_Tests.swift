import XCTest
import CardinalMobile
@testable import BraintreeCore
@testable import BraintreePaymentActions

@MainActor
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
        threeDSecureLaunchOptions: BTThreeDSecureLaunchOptions = BTThreeDSecureLaunchOptions(),
        isApplicationActive: Bool = true,
        challengeWatchdogTimeoutNanoseconds: UInt64 = 60_000_000_000
    ) throws -> BTPaymentActionThreeDSecureProvider {
        try BTPaymentActionThreeDSecureProvider(
            configuration: configuration,
            threeDSecureLaunchOptions: threeDSecureLaunchOptions,
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

    // MARK: - init(configuration:threeDSecureLaunchOptions:) - Cardinal configuration mapping

    func testInit_defaultLaunchOptions_configuresCardinalWithLegacyEquivalentDefaults() throws {
        // Cardinal's own `CardinalSessionConfiguration` pre-fills `renderType` (and, per the next
        // assertion, `uiCustomization`) with its own non-nil defaults; when the launch option is nil,
        // we leave that default untouched rather than overriding it — matching the existing 3DS
        // flow's behavior of only setting these when non-nil.
        let freshConfiguration = CardinalSessionConfiguration()
        let untouchedRenderTypeDefault = freshConfiguration.renderType

        _ = try makeSut()

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertEqual(cardinalConfiguration.uiType, .both)
        XCTAssertEqual(cardinalConfiguration.renderType, untouchedRenderTypeDefault)

        // Not XCTAssertNil/XCTAssertEqual: printing a failing Cardinal `UiCustomization` value for the
        // assertion message crashes the test process (confirmed via a live crash reproduction), so this
        // check never hands the object itself to anything that might print it.
        if (cardinalConfiguration.uiCustomization == nil) != (freshConfiguration.uiCustomization == nil) {
            XCTFail("Expected uiCustomization to remain Cardinal's own default when the launch option is nil")
        }

        XCTAssertNil(cardinalConfiguration.threeDSRequestorAppURL)
    }

    func testInit_customUIType_setsCardinalUIType() throws {
        let options = BTThreeDSecureLaunchOptions()
        options.uiType = .native

        _ = try makeSut(threeDSecureLaunchOptions: options)

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertEqual(cardinalConfiguration.uiType, .native)
    }

    func testInit_renderTypesSet_setsCardinalRenderType() throws {
        let options = BTThreeDSecureLaunchOptions()
        options.renderTypes = [.otp, .html]

        _ = try makeSut(threeDSecureLaunchOptions: options)

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertEqual(cardinalConfiguration.renderType, [CardinalSessionRenderTypeOTP, CardinalSessionRenderTypeHTML])
    }

    func testInit_uiCustomizationSet_setsCardinalUICustomization() throws {
        let options = BTThreeDSecureLaunchOptions()
        options.uiCustomization = BTThreeDSecureLaunchUICustomization()

        _ = try makeSut(threeDSecureLaunchOptions: options)

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertNotNil(cardinalConfiguration.uiCustomization)
    }

    func testInit_requestorAppURLSet_passedToCardinalAsProvided() throws {
        let options = BTThreeDSecureLaunchOptions()
        options.requestorAppURL = URL(string: "https://merchant.example.com/return")!

        _ = try makeSut(threeDSecureLaunchOptions: options)

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertEqual(cardinalConfiguration.threeDSRequestorAppURL, "https://merchant.example.com/return")
    }

    func testInit_requestorAppURLNil_nothingSetOnCardinal() throws {
        _ = try makeSut()

        let cardinalConfiguration = try XCTUnwrap(mockCardinalSession.capturedConfiguration)
        XCTAssertNil(cardinalConfiguration.threeDSRequestorAppURL)
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
