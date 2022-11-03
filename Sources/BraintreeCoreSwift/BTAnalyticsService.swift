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

/// Encapsulates analytics events for a given session
struct BTAnalyticsSession {

    let sessionID: String
    let source: String
    let integration: String

    var events: [BTAnalyticsEvent] = []

    /// Dictionary of analytics metadata from `BTAnalyticsMetadata`
    let metadataParameters: [String: Any] = BTAnalyticsMetadata.metadata
}

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// A serial dispatch queue that synchronizes access to `analyticsSessions`
    let sessionsQueue: DispatchQueue = DispatchQueue(label: "com.braintreepayments.BTAnalyticsService")

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?

    /// Defaults to 1, can be overridden
    var flushThreshold: Int

    /// Dictionary of analytics sessions, keyed by session ID. The analytics service requires that batched events
    /// are sent from only one session. In practice, BTAPIClient.metadata.sessionID should never change, so this
    /// is defensive.
    var analyticsSessions: [String: BTAnalyticsSession] = [:]

    private let apiClient: BTAPIClient

    // MARK: - Initializer

    init(apiClient: BTAPIClient, flushThreshold: Int = 1) {
        self.apiClient = apiClient
        self.flushThreshold = flushThreshold
    }

    // MARK: - Internal Methods

    ///  Tracks an event.
    ///
    ///  Events are queued and sent in batches to the analytics service, based on the status of the app and
    ///  the number of queued events. After exiting this method, there is no guarantee that the event has been sent.
    /// - Parameter eventName: String representing the event name
    func sendAnalyticsEvent(_ eventName: String) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventName)
            self.flushIfAtThreshold()
        }
    }

    func sendAnalyticsEvent(_ eventName: String, completion: @escaping (Error?) -> Void = { _ in }) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventName)
            self.flush(completion)
        }
    }

    func flush(_ completion: @escaping (Error?) -> Void = { _ in }) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                if let error {
                    completion(error)
                }
                return
            }

            guard let analyticsURL = configuration.json?["analytics"]["url"].asURL() else {
                completion(BTAnalyticsServiceError.missingAnalyticsURL)
                return
            }

            if self.http == nil {
                if let clientToken = self.apiClient.clientToken {
                    self.http = BTHTTP(url: analyticsURL, authorizationFingerprint: clientToken.authorizationFingerprint)
                } else if let tokenizationKey = self.apiClient.tokenizationKey {
                    self.http = BTHTTP(url: analyticsURL, tokenizationKey: tokenizationKey)
                } else {
                    completion(BTAnalyticsServiceError.invalidAPIClient)
                    return
                }
            }

            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if self.http?.baseURL.absoluteString == "test://do-not-send.url" {
                completion(nil)
                return
            }

            self.sessionsQueue.async {
                if self.analyticsSessions.count == 0 {
                    completion(nil)
                    return
                }

                let willPostAnalyticsEvent = !self.analyticsSessions.keys.isEmpty

                self.analyticsSessions.keys.forEach { sessionID in
                    let postParameters = self.createAnalyticsEvent(with: sessionID)
                    self.http?.post("/", parameters: postParameters) { body, response, error in
                        if let error {
                            completion(error)
                        }
                    }
                }

                if !willPostAnalyticsEvent {
                    completion(nil)
                }

                completion(nil)
            }
        }
    }

    // MARK: - Helpers

    func enqueueEvent(_ eventName: String) {
        let timestampInMilliseconds = Date().timeIntervalSince1970 * 1000
        let event = BTAnalyticsEvent(eventName: eventName, timestamp: UInt64(timestampInMilliseconds))
        let session = BTAnalyticsSession(
            sessionID: apiClient.metadata.sessionID,
            source: apiClient.metadata.sourceString,
            integration: apiClient.metadata.integrationString
        )

        sessionsQueue.async {
            if self.analyticsSessions[session.sessionID] == nil {
                self.analyticsSessions[session.sessionID] = session
            }

            self.analyticsSessions[session.sessionID]?.events.append(event)
        }
    }

    func flushIfAtThreshold() {
        var eventCount = 0

        sessionsQueue.sync {
            analyticsSessions.values.forEach { analyticsSession in
                eventCount += analyticsSession.events.count
            }
        }

        if eventCount >= flushThreshold {
            flush()
        }
    }

    func createAnalyticsEvent(with sessionID: String) -> [String: Any] {
        var session = self.analyticsSessions[sessionID]
        let metadataParameters: [String: Any] = [
            "sessionId": session?.sessionID ?? "",
            "integrationType": session?.integration ?? "",
            "source": session?.source ?? ""
        ]
            .merging(session?.metadataParameters ?? [:]) { $1 }

        var postParameters: [String: Any] = [:]

        if let sessionEvents = session?.events {
            // Map array of BTAnalyticsEvent to JSON
            postParameters["analytics"] = sessionEvents.map { $0.json }
        }

        postParameters["_meta"] = metadataParameters

        if let authorizationFingerprint = self.apiClient.clientToken?.authorizationFingerprint {
            postParameters["authorization_fingerprint"] = authorizationFingerprint
        } else if let tokenizationKey = self.apiClient.tokenizationKey {
            postParameters["tokenization_key"] = tokenizationKey
        }

        session?.events.removeAll()
        return postParameters
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.flushThreshold == rhs.flushThreshold && lhs.apiClient == rhs.apiClient
    }
}
