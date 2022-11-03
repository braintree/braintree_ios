import Foundation

/// Encapsulates a single analytics event
struct BTAnalyticsEvent {

    var eventName: String
    var timestamp: UInt64

    var description: String {
        "\(eventName) at \(timestamp)"
    }

    /// Event serialized to JSON
    var json: [String: Any] {
        [
            "eventName": eventName,
            "timestamp": timestamp
        ]
    }
}
