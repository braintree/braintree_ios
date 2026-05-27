import Foundation

/// Represents a PayPal app switch billing agreement session that can be retried after the merchant app returns to the foreground.
struct BTPayPalAppSwitchSession {

    /// The billing agreement token returned by PayPal for the app switch flow.
    let baToken: String

    /// The risk correlation ID associated with the billing agreement token.
    let correlationID: String?

    /// The time when the app switch session started.
    let startedAt: Date

    /// The maximum time a pending app switch session remains valid.
    static let ttl: TimeInterval = 1800

    /// Indicates whether the pending app switch session has exceeded its TTL.
    var isExpired: Bool {
        Date().timeIntervalSince(startedAt) > BTPayPalAppSwitchSession.ttl
    }
}
