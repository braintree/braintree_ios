import XCTest
@testable import BraintreePayPal

class BTPayPalAppSwitchSession_Tests: XCTestCase {

    // MARK: - isExpired

    func testIsExpired_whenWithinTTL_returnsFalse() {
        let session = BTPayPalAppSwitchSession(
            paymentType: .vault,
            startedAt: Date()
        )
        XCTAssertFalse(session.isExpired)
    }

    func testIsExpired_whenPastTTL_returnsTrue() {
        let startedAt = Date(timeIntervalSinceNow: -(BTPayPalAppSwitchSession.ttl + 1))
        let session = BTPayPalAppSwitchSession(
            paymentType: .vault,
            startedAt: startedAt
        )
        XCTAssertTrue(session.isExpired)
    }

    func testIsExpired_whenExactlyAtTTLBoundary_returnsFalse() {
        let now = Date()
        let startedAt = now.addingTimeInterval(-BTPayPalAppSwitchSession.ttl)
        let session = BTPayPalAppSwitchSession(
            paymentType: .vault,
            startedAt: startedAt
        )
        XCTAssertFalse(session.isExpired(at: now))
    }

    func testInit_storesVaultPaymentType() {
        let session = BTPayPalAppSwitchSession(
            paymentType: .vault,
            startedAt: Date()
        )
        XCTAssertEqual(session.paymentType, .vault)
    }

    func testInit_storesCheckoutPaymentType() {
        let session = BTPayPalAppSwitchSession(
            paymentType: .checkout,
            startedAt: Date()
        )
        XCTAssertEqual(session.paymentType, .checkout)
    }
}

class BTPayPalInMemoryPendingStore_Tests: XCTestCase {

    var store: BTPayPalInMemoryPendingStore!

    override func setUp() {
        super.setUp()
        store = BTPayPalInMemoryPendingStore()
    }

    func testRead_whenEmpty_returnsNil() async {
        let session = await store.read()
        XCTAssertNil(session)
    }

    func testStore_thenRead_returnsSameSession() async {
        let session = BTPayPalAppSwitchSession(paymentType: .vault)
        await store.store(session)

        let storedSession = await store.read()
        XCTAssertEqual(storedSession?.paymentType, .vault)
    }

    func testClear_afterStore_returnsNil() async {
        await store.store(BTPayPalAppSwitchSession(paymentType: .vault))
        await store.clear()

        let session = await store.read()
        XCTAssertNil(session)
    }

    func testStore_calledTwice_overwritesPreviousSession() async {
        await store.store(BTPayPalAppSwitchSession(paymentType: .vault))
        await store.store(BTPayPalAppSwitchSession(paymentType: .checkout))

        let session = await store.read()
        XCTAssertEqual(session?.paymentType, .checkout)
    }
}
