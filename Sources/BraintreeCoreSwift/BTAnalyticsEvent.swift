import Foundation

/// Encapsulates a single analytics event
struct BTAnalyticsEvent {
    var kind: String
    var timestamp: Double

    var description: String {
        "\(kind) at \(timestamp)"
    }

    /// Event serialized to JSON
    var json: [String: Any] {
        [
            "kind": kind,
            "timestamp": timestamp
        ]
    }

    func event(_ eventKind: String, withTimestamp timestamp: Double) -> BTAnalyticsEvent {
        BTAnalyticsEvent(kind: eventKind, timestamp: timestamp)
    }
}
