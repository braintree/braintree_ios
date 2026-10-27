import XCTest
@testable import BraintreePaymentActions

class NextActionHandler_Tests: XCTestCase {

    // MARK: - drive() - Non-processing statuses return immediately

    func testDrive_requiresCustomerAction_returnsImmediatelyWithoutLooping() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(id: "pa-id", status: .requiresCustomerAction)
        }

        let result = try await handler.drive()

        XCTAssertEqual(result.status, .requiresCustomerAction)
        XCTAssertEqual(fetchCount, 1)
    }

    func testDrive_readyForConfirmation_returnsImmediately() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .readyForConfirmation)
        }

        let result = try await handler.drive()

        XCTAssertEqual(result.status, .readyForConfirmation)
    }

    func testDrive_succeeded_returnsImmediately() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .succeeded)
        }

        let result = try await handler.drive()

        XCTAssertEqual(result.status, .succeeded)
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

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(fetchCount, 2)
    }

    func testDrive_processingNeverResolves_returnsProcessingAfterThreeAttempts() async throws {
        var fetchCount = 0
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            fetchCount += 1
            return BTPaymentAction(id: "pa-id", status: .processing)
        }

        let result = try await handler.drive()

        XCTAssertEqual(result.status, .processing)
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

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.version, 3)
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

        XCTAssertEqual(result.status, .processing)
        XCTAssertEqual(fetchCount, 3)
    }

    func testDrive_missingVersion_doesNotThrow() async throws {
        let handler = NextActionHandler(processingRetryDelayNanoseconds: 0) {
            BTPaymentAction(id: "pa-id", status: .succeeded)
        }

        let result = try await handler.drive()

        XCTAssertNil(result.version)
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
}
