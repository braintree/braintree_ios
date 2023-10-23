import Foundation

/// Encapsulates analytics events for a given session
struct BTAnalyticsSession {

    let sessionID: String
    var events: [FPTIBatchData.Event] = []
    
    init(with sessionID: String) {
        self.sessionID = sessionID
    }
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
    
    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api-m.paypal.com")!

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
    func sendAnalyticsEvent(_ eventName: String, errorDescription: String? = nil, correlationID: String? = nil) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventName, errorDescription: errorDescription, correlationID: correlationID)
            self.flushIfAtThreshold()
        }
    }

    /// Sends request to FPTI immediately, without checking number of events in queue against flush threshold
    func sendAnalyticsEvent(
        _ eventName: String,
        errorDescription: String? = nil,
        correlationID: String? = nil,
        completion: @escaping (Error?) -> Void = { _ in }
    ) {
        DispatchQueue.main.async {
            self.enqueueEvent(eventName, errorDescription: errorDescription, correlationID: correlationID)
            self.flush(completion)
        }
    }

    /// Executes API request to FPTI
    func flush(_ completion: @escaping (Error?) -> Void = { _ in }) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                if let error {
                    completion(error)
                }
                return
            }

            // TODO: - Refactor to make HTTP non-optional property and instantiate in init()
            if self.http == nil {
                if let clientToken = self.apiClient.clientToken {
                    self.http = BTHTTP(url: BTAnalyticsService.url, authorizationFingerprint: clientToken.authorizationFingerprint)
                } else if let tokenizationKey = self.apiClient.tokenizationKey {
                    self.http = BTHTTP(url: BTAnalyticsService.url, tokenizationKey: tokenizationKey)
                } else {
                    completion(BTAnalyticsServiceError.invalidAPIClient)
                    return
                }
            }

            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if let http = self.http, http.baseURL.absoluteString == "test://do-not-send.url" {
                completion(nil)
                return
            }

            self.sessionsQueue.async {
                if self.analyticsSessions.count == 0 {
                    completion(nil)
                    return
                }

                self.analyticsSessions.keys.forEach { sessionID in
                    let postParameters = self.createAnalyticsEvent(config: configuration, sessionID: sessionID)
                    self.http?.post("v1/tracking/batch/events", parameters: postParameters) { body, response, error in
                        if let error {
                            completion(error)
                        }
                    }
                }
                completion(nil)
            }
        }
    }

    // MARK: - Helpers

    /// Adds an event to the queue
    func enqueueEvent(_ eventName: String, errorDescription: String?, correlationID: String?) {
        let timestampInMilliseconds = UInt64(Date().timeIntervalSince1970 * 1000)
        let event = FPTIBatchData.Event(
            correlationID: correlationID,
            errorDescription: errorDescription,
            eventName: eventName,
            timestamp: String(timestampInMilliseconds)
        )
        let session = BTAnalyticsSession(with: apiClient.metadata.sessionID)

        sessionsQueue.async {
            if self.analyticsSessions[session.sessionID] == nil {
                self.analyticsSessions[session.sessionID] = session
            }

            self.analyticsSessions[session.sessionID]?.events.append(event)
        }
    }

    /// Checks queued event count to determine if ready to fire API request
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

    /// Constructs POST params to be sent to FPTI from the queued events in the session
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient.clientToken?.authorizationFingerprint,
            environment: config.fptiEnvironment,
            integrationType: apiClient.metadata.integration.stringValue,
            merchantID: config.merchantID,
            sessionID: sessionID,
            tokenizationKey: apiClient.tokenizationKey
        )
        
        let session = self.analyticsSessions[sessionID]

        return FPTIBatchData(metadata: batchMetadata, events: session?.events)
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.flushThreshold == rhs.flushThreshold && lhs.apiClient == rhs.apiClient
    }
}
