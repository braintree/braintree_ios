import Foundation

/// Represents a PayPal app switch session that can be retried after the merchant app returns to the foreground.
struct BTPayPalAppSwitchSession {

    /// The PayPal payment type associated with the app switch flow.
    let paymentType: BTPayPalPaymentType

    /// The time when the app switch session started.
    let startedAt: Date

    /// The maximum time a pending app switch session remains valid.
    static let ttl: TimeInterval = 1800

    /// Indicates whether the pending app switch session has exceeded its TTL.
    var isExpired: Bool {
        isExpired(at: Date())
    }

    init(
        paymentType: BTPayPalPaymentType,
        startedAt: Date = Date()
    ) {
        self.paymentType = paymentType
        self.startedAt = startedAt
    }

    func isExpired(at date: Date) -> Bool {
        date.timeIntervalSince(startedAt) > BTPayPalAppSwitchSession.ttl
    }
}
