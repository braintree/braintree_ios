import Foundation

/// Encapsulates analytics events for a given session
struct BTAnalyticsSession {

    let sessionID: String
    let source: String
    let integration: String

    var events: [BTAnalyticsEvent] = []

    /// Dictionary of analytics metadata from `BTAnalyticsMetadata`
    let metadataParameters: [String: Any] = BTAnalyticsMetadata.metadata

    func sessionWithID(_ sessionID: String, source: String, integration: String) -> BTAnalyticsSession {
        BTAnalyticsSession(sessionID: sessionID, source: source, integration: integration)
    }
}
