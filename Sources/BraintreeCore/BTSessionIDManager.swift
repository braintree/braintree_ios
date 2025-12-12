import Foundation

/// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Manages a shared session ID across all Braintree payment components to enable end-to-end analytics tracking.
@_documentation(visibility: private)
public class BTSessionIDManager {

    // MARK: - Singleton Setup
    public static let shared = BTSessionIDManager()

    let sessionID: String
    private let lock = NSLock()

    private init() {
        self.sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
