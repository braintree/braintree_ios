import XCTest
@testable import BraintreePayPal

class BTPayPalAppSwitchSession_Tests: XCTestCase {

    // MARK: - isExpired

    func testIsExpired_whenWithinTTL_returnsFalse() {
        let session = BTPayPalAppSwitchSession(
            baToken: "BA-123",
            correlationID: nil,
            startedAt: Date()
        )
        XCTAssertFalse(session.isExpired)
    }

    func testIsExpired_whenPastTTL_returnsTrue() {
        let startedAt = Date(timeIntervalSinceNow: -(BTPayPalAppSwitchSession.ttl + 1))
        let session = BTPayPalAppSwitchSession(
            baToken: "BA-123",
            correlationID: nil,
            startedAt: startedAt
        )
        XCTAssertTrue(session.isExpired)
    }

    func testIsExpired_whenExactlyAtTTLBoundary_returnsFalse() {
        let startedAt = Date(timeIntervalSinceNow: -BTPayPalAppSwitchSession.ttl)
        let session = BTPayPalAppSwitchSession(
            baToken: "BA-123",
            correlationID: nil,
            startedAt: startedAt
        )
        XCTAssertFalse(session.isExpired)
    }

    func testIsExpired_storesCorrelationIDAndBAToken() {
        let session = BTPayPalAppSwitchSession(
            baToken: "BA-ABC",
            correlationID: "correlation-xyz",
            startedAt: Date()
        )
        XCTAssertEqual(session.baToken, "BA-ABC")
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
        let session = BTPayPalAppSwitchSession(baToken: "BA-123", correlationID: nil, startedAt: Date())
        store.store(session)
        XCTAssertEqual(store.read()?.baToken, "BA-123")
    }

    func testClear_afterStore_returnsNil() {
        store.store(BTPayPalAppSwitchSession(baToken: "BA-123", correlationID: nil, startedAt: Date()))
        store.clear()
        XCTAssertNil(store.read())
    }

    func testStore_calledTwice_overwritesPreviousSession() {
        store.store(BTPayPalAppSwitchSession(baToken: "BA-FIRST", correlationID: nil, startedAt: Date()))
        store.store(BTPayPalAppSwitchSession(baToken: "BA-SECOND", correlationID: nil, startedAt: Date()))
        XCTAssertEqual(store.read()?.baToken, "BA-SECOND")
    }
}
