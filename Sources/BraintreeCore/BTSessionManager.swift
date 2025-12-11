import Foundation

/// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Manages a shared session ID across all Braintree payment components to enable end-to-end analytics tracking.

@_documentation(visibility: private)
public class BTSessionManager {

    // MARK: - Singleton Setup
    public static let shared = BTSessionManager()

    private var currentSessionID: String?
    private let lock = NSLock()

    private init() {}

    // MARK: - Internal Methods

    /// Checks for existing session ID. If a session ID doesn't exist, it creates one to be reused across a single customer session.
    public func getOrCreateSessionID() -> String {
        lock.lock()
        defer { lock.unlock() }

        if let existingSessionID = currentSessionID {
            return existingSessionID
        }

        let newSessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        currentSessionID = newSessionID
        return newSessionID
    }
}
