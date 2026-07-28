import XCTest
@testable import BraintreePayPal

class BTPayPalAppSwitchSession_Tests: XCTestCase {

    // MARK: - isExpired

    func testIsExpired_whenWithinTTL_returnsFalse() {
        let session = BTPayPalAppSwitchSession(
            contextID: "BA-123",
            paymentType: .vault,
            correlationID: nil,
            startedAt: Date()
        )
        XCTAssertFalse(session.isExpired)
    }

    func testIsExpired_whenPastTTL_returnsTrue() {
        let startedAt = Date(timeIntervalSinceNow: -(BTPayPalAppSwitchSession.ttl + 1))
        let session = BTPayPalAppSwitchSession(
            contextID: "BA-123",
            paymentType: .vault,
            correlationID: nil,
            startedAt: startedAt
        )
        XCTAssertTrue(session.isExpired)
    }

    func testIsExpired_whenExactlyAtTTLBoundary_returnsFalse() {
        let now = Date()
        let startedAt = now.addingTimeInterval(-BTPayPalAppSwitchSession.ttl)
        let session = BTPayPalAppSwitchSession(
            contextID: "BA-123",
            paymentType: .vault,
            correlationID: nil,
            startedAt: startedAt
        )
        XCTAssertFalse(session.isExpired(at: now))
    }

    func testInit_storesVaultContext() {
        let session = BTPayPalAppSwitchSession(
            contextID: "BA-ABC",
            paymentType: .vault,
            correlationID: "correlation-xyz",
            startedAt: Date()
        )
        XCTAssertEqual(session.contextID, "BA-ABC")
        XCTAssertEqual(session.paymentType, .vault)
        XCTAssertEqual(session.correlationID, "correlation-xyz")
    }

    func testInit_storesCheckoutContext() {
        let session = BTPayPalAppSwitchSession(
            contextID: "EC-ABC",
            paymentType: .checkout,
            correlationID: "correlation-xyz",
            startedAt: Date()
        )
        XCTAssertEqual(session.contextID, "EC-ABC")
        XCTAssertEqual(session.paymentType, .checkout)
        XCTAssertEqual(session.correlationID, "correlation-xyz")
    }
}

class BTPayPalInMemoryPendingStore_Tests: XCTestCase {

    var store: BTPayPalInMemoryPendingStore!

    override func setUp() {
        super.setUp()
        store = BTPayPalInMemoryPendingStore()
    }

    func testRead_whenEmpty_returnsNil() {
        XCTAssertNil(store.read())
    }

    func testStore_thenRead_returnsSameSession() {
        let session = BTPayPalAppSwitchSession(contextID: "BA-123", paymentType: .vault, correlationID: nil)
        store.store(session)
        XCTAssertEqual(store.read()?.contextID, "BA-123")
        XCTAssertEqual(store.read()?.paymentType, .vault)
    }

    func testClear_afterStore_returnsNil() {
        store.store(BTPayPalAppSwitchSession(contextID: "BA-123", paymentType: .vault, correlationID: nil))
        store.clear()
        XCTAssertNil(store.read())
    }

    func testStore_calledTwice_overwritesPreviousSession() {
        store.store(BTPayPalAppSwitchSession(contextID: "BA-FIRST", paymentType: .vault, correlationID: nil))
        store.store(BTPayPalAppSwitchSession(contextID: "EC-SECOND", paymentType: .checkout, correlationID: nil))
        XCTAssertEqual(store.read()?.contextID, "EC-SECOND")
        XCTAssertEqual(store.read()?.paymentType, .checkout)
    }
}
