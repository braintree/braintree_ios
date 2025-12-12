import Foundation

/// Manages a shared session ID across all Braintree payment components to enable end-to-end analytics tracking.
class BTSessionIDManager {
    
    static let shared = BTSessionIDManager()
    let sessionID: String

    private init() {
        self.sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
