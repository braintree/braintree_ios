import XCTest
@testable import BraintreePaymentActions

class NextActionHandler_Tests: XCTestCase {

    // MARK: - Helpers

    private func paymentAction(from result: NextActionHandler.DriveResult) -> BTPaymentAction? {
        guard case .paymentAction(let paymentAction) = result else {
            return nil
        }
        return paymentAction
    }

    // MARK: - drive() - Non-processing statuses return immediately

    func testDrive_requiresCustomerAction_noNextAction_returnsImmediatelyWithoutLooping() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(id: "pa-id", status: .requiresCustomerAction)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .requiresCustomerAction)
        XCTAssertEqual(fetchCount, 1)
    }

    func testDrive_readyForConfirmation_returnsImmediately() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .readyForConfirmation)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .readyForConfirmation)
    }

    func testDrive_succeeded_returnsImmediately() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .succeeded)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .succeeded)
    }

    // MARK: - drive() - Bounded PROCESSING re-checks

    func testDrive_processingResolvesOnSecondFetch_returnsResolvedStatus() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(
                id: "pa-id",
                status: fetchCount == 1 ? .processing : .succeeded
            )
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .succeeded)
        XCTAssertEqual(fetchCount, 2)
    }

    func testDrive_processingNeverResolves_returnsProcessingAfterThreeAttempts() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(id: "pa-id", status: .processing)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .processing)
        XCTAssertEqual(fetchCount, 3)
    }

    // MARK: - drive() - Version tracking

    func testDrive_versionIncreasesAcrossFetches_doesNotThrow() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(
                id: "pa-id",
                status: fetchCount < 3 ? .processing : .succeeded,
                version: fetchCount
            )
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .succeeded)
        XCTAssertEqual(paymentAction(from: result)?.version, 3)
    }

    func testDrive_versionDecreasesAcrossFetches_throwsVersionAnomaly() async {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(
                id: "pa-id",
                status: .processing,
                version: fetchCount == 1 ? 5 : 4
            )
        }

        do {
            _ = try await handler.drive()
            XCTFail("Expected versionAnomaly to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .versionAnomaly)
        }
    }

    func testDrive_versionUnchangedAcrossProcessingFetches_doesNotThrow() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(id: "pa-id", status: .processing, version: 2)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .processing)
        XCTAssertEqual(fetchCount, 3)
    }

    func testDrive_missingVersion_doesNotThrow() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .succeeded)
        }

        let result = try await handler.drive()

        XCTAssertNil(paymentAction(from: result)?.version)
    }

    // MARK: - drive() - Error propagation

    func testDrive_fetchThrows_propagatesError() async {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            throw BTPaymentActionError.missingID
        }

        do {
            _ = try await handler.drive()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .missingID)
        }
    }

    // MARK: - drive() - Customer action resolution

    func testDrive_requiresCustomerAction_unrecognizedNextAction_returnsImmediatelyWithoutResolving() async throws {
        var resolveCalled = false
        let handler = NextActionHandler(
            processingRetryDelayNanoseconds: 0,
            fetchPaymentAction: {
                BTPaymentAction(id: "pa-id", status: .requiresCustomerAction, nextAction: .unrecognized(typeName: "Foo"))
            },
            resolveCustomerAction: { _ in
                resolveCalled = true
                return .advanced(BTPaymentAction(id: "pa-id", status: .succeeded))
            }
        )

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .requiresCustomerAction)
        XCTAssertFalse(resolveCalled)
    }

    func testDrive_requiresCustomerAction_noResolver_returnsImmediatelyEvenWithRecognizedNextAction() async throws {
        let nextAction = BTNextAction.threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .requiresCustomerAction, nextAction: nextAction)
        }

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .requiresCustomerAction)
    }

    func testDrive_requiresCustomerAction_resolverAdvances_continuesLoopingOnNewState() async throws {
        let nextAction = BTNextAction.threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        var fetchCount = 0
        var resolveCount = 0

        let handler = NextActionHandler(
            processingRetryDelayNanoseconds: 0,
            fetchPaymentAction: {
                fetchCount += 1
                return BTPaymentAction(id: "pa-id", status: .requiresCustomerAction, nextAction: nextAction)
            },
            resolveCustomerAction: { _ in
                resolveCount += 1
                return .advanced(BTPaymentAction(id: "pa-id", status: .readyForConfirmation))
            }
        )

        let result = try await handler.drive()

        XCTAssertEqual(paymentAction(from: result)?.status, .readyForConfirmation)
        XCTAssertEqual(fetchCount, 1)
        XCTAssertEqual(resolveCount, 1)
    }

    func testDrive_requiresCustomerAction_resolverAbandoned_returnsThreeDSecureCanceled() async throws {
        let nextAction = BTNextAction.threeDSecureChallenge(
            BTPaymentActionThreeDSecureChallengeNextAction(
                acsURL: URL(string: "https://acs.example.com")!,
                acsRenderingType: nil,
                challengePayload: "payload",
                mpiTransactionID: "mpi-1"
            )
        )
        let handler = NextActionHandler(
            processingRetryDelayNanoseconds: 0,
            fetchPaymentAction: {
                BTPaymentAction(id: "pa-id", status: .requiresCustomerAction, nextAction: nextAction)
            },
            resolveCustomerAction: { _ in .abandoned }
        )

        let result = try await handler.drive()

        XCTAssertEqual(result, .threeDSecureCanceled(id: "pa-id"))
    }

    func testDrive_requiresCustomerAction_resolverThrows_propagatesError() async {
        let nextAction = BTNextAction.threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        let handler = NextActionHandler(
            processingRetryDelayNanoseconds: 0,
            fetchPaymentAction: {
                BTPaymentAction(id: "pa-id", status: .requiresCustomerAction, nextAction: nextAction)
            },
            resolveCustomerAction: { _ in throw BTPaymentActionError.cardinalChallengeFailed }
        )

        do {
            _ = try await handler.drive()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? BTPaymentActionError, .cardinalChallengeFailed)
        }
    }
}
