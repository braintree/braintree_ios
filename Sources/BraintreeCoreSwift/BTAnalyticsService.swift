import Foundation

class BTAnalyticsService {

    // MARK: - Internal Properties

    let apiClient: BTAPIClient

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    let http: BTHTTP?

    /// A serial dispatch queue that synchronizes access to `analyticsSessions`
    let sessionsQueue: DispatchQueue = DispatchQueue(label: "com.braintreepayments.BTAnalyticsService")

    /// Defaults to 1, can be overridden
    var flushThreshold: Int

    /// Dictionary of analytics sessions, keyed by session ID. The analytics service requires that batched events
    /// are sent from only one session. In practice, BTAPIClient.metadata.sessionID should never change, so this
    /// is defensive.
    var analyticsSessions: [String: BTAnalyticsSession] = [:]

    // MARK: - Initializer

    init(apiClient: BTAPIClient, flushThreshold: Int = 1) {
        self.apiClient = apiClient
    }

    // MARK: - Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Internal Methods

    ///  Tracks an event.
    ///
    ///  Events are queued and sent in batches to the analytics service, based on the status of the app and
    ///  the number of queued events. After exiting this method, there is no guarantee that the event has been sent.
    /// - Parameter eventKind: String representing the event kind
    func sendAnalyticsEvent(_ eventKind: String) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventKind)
            self.checkFlushThreshold()
        }
    }

    func sendAnalyticsEvent(_ eventKind: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventKind)
            self.flush(completion)
        }
    }

    func flush(_ completion: ((Error?) -> Void)? = { _ in }) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                if let completion {
                    completion(error?.localizedDescription)
                    return
                }
            }

            guard let analyticsURL = configuration.json["analytics"]["url"].asURL() else {
                completion(BTAnalyticsServiceError.missingAnalyticsURL)
                return
            }

            if let http {
                if let clientToken = apiClient.clientToken {
                    http = BTHTTP(url: analyticsURL, authorizationFingerprint: clientToken.authorizationFingerprint)
                } else if let tokenizationKey = apiClient.tokenizationKey {
                    http = BTHTTP(url: analyticsURL, tokenizationKey: tokenizationKey)
                }
            } else {
                completion(BTAnalyticsServiceError.invalidAPIClient)
                return
            }

            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if http?.baseURL == "test://do-not-send.url" {
                completion(nil)
                return
            }

            sessionsQueue.async {
                if analyticsSessions.count == 0 {
                    completion(nil)
                    return
                }

                var willPostAnalyticsEvent: Bool = false

                analyticsSessions.keys.forEach { sessionID in
                    let session = analyticsSessions[sessionID]
                    if session?.events.count == 0 {
                        continue
                    }

                    willPostAnalyticsEvent = true

                    var metadataParameters: [String: Any] = [
                        "sessionId": session?.sessionID,
                        "integrationType": session?.integration,
                        "source": session?.source
                    ]

                    var postParameters: [String: Any] = [:]

                    if session?.events {
                        // Map array of BTAnalyticsEvent to JSON
                        postParameters["analytics"] = session?.events["json"]
                    }

                    postParameters["_meta"] = metadataParameters

                    if let authorizationFingerprint = apiClient.clientToken?.authorizationFingerprint {
                        postParameters["authorization_fingerprint"] = authorizationFingerprint
                    } else if let tokenizationKey = apiClient.tokenizationKey {
                        postParameters["tokenization_key"] = tokenizationKey
                    }

                    session?.events.removeAllObjects()

                    http?.post("/", parameters: postParameters) { body, response, error in
                        if let error {
                            completion(error.localizedDescription)
                        }
                    }
                }

                if !willPostAnalyticsEvent {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Helpers

    func enqueueEvent(_ eventKind: String) {
        let timestampInMilliseconds = Date().timeIntervalSince1970 * 1000
        let event = BTAnalyticsEvent(kind: eventKind, timestamp: timestampInMilliseconds)
        let session = BTAnalyticsSession(
            sessionID: apiClient.metadata?.sessionID ?? "",
            source: apiClient.metadata?.sourceString ?? "",
            integration: apiClient.metadata?.integrationString ?? ""
        )

        if session.sessionID == "" || session.source == "" || session.integration == "" {
            let description = BTLogLevelDescription.string(for: .warning) ?? ""
            print("\(description) Missing analytics session metadata - will not send event \(event.kind)")
            return
        }

        sessionsQueue.async {
            if self.analyticsSessions[session.sessionID] == nil {
                self.analyticsSessions[session.sessionID] = session
            }

            self.analyticsSessions[session.sessionID]?.events.append(event)
        }
    }

    func checkFlushThreshold() {
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
}
