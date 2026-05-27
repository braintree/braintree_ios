import Foundation

struct BTPayPalAppSwitchSession {

    let baToken: String
    let correlationID: String?
    let startedAt: Date

    static let ttl: TimeInterval = 1800

    var isExpired: Bool {
        Date().timeIntervalSince(startedAt) > BTPayPalAppSwitchSession.ttl
    }
}
