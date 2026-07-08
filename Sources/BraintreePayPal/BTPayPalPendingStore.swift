import Foundation

/// Stores the pending PayPal app switch session in memory while the merchant app is backgrounded.
/// Pending sessions are not persisted across app launches.
protocol BTPayPalPendingStoreProtocol: Actor {

    /// Saves a pending PayPal app switch session.
    func store(_ session: BTPayPalAppSwitchSession) async

    /// Returns the currently pending PayPal app switch session.
    func read() async -> BTPayPalAppSwitchSession?

    /// Clears the currently pending PayPal app switch session.
    func clear() async
}

/// In-memory storage for a pending PayPal app switch session.
actor BTPayPalInMemoryPendingStore: BTPayPalPendingStoreProtocol {

    /// The currently pending PayPal app switch session.
    private var session: BTPayPalAppSwitchSession?

    /// Saves a pending PayPal app switch session.
    func store(_ session: BTPayPalAppSwitchSession) async {
        self.session = session
    }

    /// Returns the currently pending PayPal app switch session.
    func read() async -> BTPayPalAppSwitchSession? {
        session
    }

    /// Clears the currently pending PayPal app switch session.
    func clear() async {
        session = nil
    }
}
