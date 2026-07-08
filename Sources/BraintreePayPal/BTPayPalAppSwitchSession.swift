import Foundation

/// Represents a PayPal app switch session that can be retried after the merchant app returns to the foreground.
struct BTPayPalAppSwitchSession {

    /// The PayPal context ID returned by PayPal for the app switch flow.
    /// This can be a billing agreement token for Vault or an EC token for Checkout.
    let contextID: String

    /// The PayPal payment type associated with the app switch flow.
    let paymentType: BTPayPalPaymentType

    /// The risk correlation ID associated with the PayPal context ID.
    let correlationID: String?

    /// The time when the app switch session started.
    let startedAt: Date

    /// The maximum time a pending app switch session remains valid.
    static let ttl: TimeInterval = 1800

    /// Indicates whether the pending app switch session has exceeded its TTL.
    var isExpired: Bool {
        isExpired(at: Date())
    }

    init(
        contextID: String,
        paymentType: BTPayPalPaymentType,
        correlationID: String?,
        startedAt: Date = Date()
    ) {
        self.contextID = contextID
        self.paymentType = paymentType
        self.correlationID = correlationID
        self.startedAt = startedAt
    }

    func isExpired(at date: Date) -> Bool {
        date.timeIntervalSince(startedAt) > BTPayPalAppSwitchSession.ttl
    }
}
