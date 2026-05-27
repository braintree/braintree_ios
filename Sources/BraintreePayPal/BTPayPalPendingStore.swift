import Foundation

protocol BTPayPalPendingStoreProtocol: AnyObject {
    func store(_ session: BTPayPalAppSwitchSession)
    func read() -> BTPayPalAppSwitchSession?
    func clear()
}

final class BTPayPalInMemoryPendingStore: BTPayPalPendingStoreProtocol {

    private var session: BTPayPalAppSwitchSession?

    func store(_ session: BTPayPalAppSwitchSession) {
        self.session = session
    }

    func read() -> BTPayPalAppSwitchSession? {
        session
    }

    func clear() {
        session = nil
    }
}
