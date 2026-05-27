import Foundation
@testable import BraintreePayPal

class MockPendingStore: BTPayPalPendingStoreProtocol {

    var storedSession: BTPayPalAppSwitchSession?
    var storeCallCount = 0
    var clearCallCount = 0

    func store(_ session: BTPayPalAppSwitchSession) {
        storedSession = session
        storeCallCount += 1
    }

    func read() -> BTPayPalAppSwitchSession? {
        storedSession
    }

    func clear() {
        storedSession = nil
        clearCallCount += 1
    }
}
