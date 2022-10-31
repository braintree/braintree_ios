import Foundation

/// Encapsulates analytics events for a given session
struct BTAnalyticsSession {

    let sessionID: String
    let source: String
    let integration: String

    var events: [BTAnalyticsEvent] = []

    /// Dictionary of analytics metadata from `BTAnalyticsMetadata`
    let metadataParameters: [String: Any] = BTAnalyticsMetadata.metadata
}
