import Foundation

/// Stores the pending PayPal app switch session while the merchant app is backgrounded.
protocol BTPayPalPendingStoreProtocol: AnyObject {

    /// Saves a pending PayPal app switch session.
    func store(_ session: BTPayPalAppSwitchSession)

    /// Returns the currently pending PayPal app switch session.
    func read() -> BTPayPalAppSwitchSession?

    /// Clears the currently pending PayPal app switch session.
    func clear()
}

/// In-memory storage for a pending PayPal app switch session.
final class BTPayPalInMemoryPendingStore: BTPayPalPendingStoreProtocol {

    /// The currently pending PayPal app switch session.
    private var session: BTPayPalAppSwitchSession?

    /// Saves a pending PayPal app switch session.
    func store(_ session: BTPayPalAppSwitchSession) {
        self.session = session
    }

    /// Returns the currently pending PayPal app switch session.
    func read() -> BTPayPalAppSwitchSession? {
        session
    }

    /// Clears the currently pending PayPal app switch session.
    func clear() {
        session = nil
    }
}
