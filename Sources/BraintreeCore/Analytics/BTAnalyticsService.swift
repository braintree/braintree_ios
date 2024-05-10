import Foundation

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?

    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api-m.paypal.com")!
    
    /// Exposed for unit tests to synchronously fire analytics
    var timerOn = true

    // MARK: - Private Properties

    private let apiClient: BTAPIClient
    private let timerInterval = 30.0
    private static var eventsQueue: [FPTIBatchData.Event] = []
    private static var timer: Timer?
    
    // MARK: - Initializer

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        
        BTAnalyticsService.timer = Timer.scheduledTimer(
            timeInterval: timerInterval,
            target: self,
            selector: #selector(flushQueue),
            userInfo: nil,
            repeats: false
        )
    }

    // MARK: - Internal Methods
    
    /// Sends analytics event to https://api.paypal.com/v1/tracking/batch/events/ via a background task.
    /// - Parameters:
    ///   - eventName: Name of analytic event.
    ///   - correlationID: Optional. CorrelationID associated with the checkout session.
    ///   - errorDescription: Optional. Full error description returned to merchant.
    ///   - linkType: Optional. The type of link the SDK will be handling, currently deeplink or universal.
    ///   - payPalContextID: Optional. PayPal Context ID associated with the checkout session.
    func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil
    ) {
        let timestampInMilliseconds = Int(round(Date().timeIntervalSince1970 * 1000))
        let event = FPTIBatchData.Event(
            correlationID: correlationID,
            errorDescription: errorDescription,
            eventName: eventName,
            linkType: linkType,
            payPalContextID: payPalContextID,
            timestamp: String(timestampInMilliseconds)
        )

        BTAnalyticsService.eventsQueue.append(event)
        
        // Exposed for unit tests
        // TODO: - Is there a cleaner way without having to add logic to test code?
        if !timerOn {
            flushQueue()
        }
    }
    
    /// Block executed repeatedly by `Timer` static property, based on set `timerInterval` property
    @objc func flushQueue() {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                return
            }

            // TODO: - Refactor to make HTTP non-optional property and instantiate in init()
            if self.http == nil {
                if let clientToken = self.apiClient.clientToken {
                    self.http = BTHTTP(url: BTAnalyticsService.url, authorizationFingerprint: clientToken.authorizationFingerprint)
                } else if let tokenizationKey = self.apiClient.tokenizationKey {
                    self.http = BTHTTP(url: BTAnalyticsService.url, tokenizationKey: tokenizationKey)
                } else {
                    return
                }
            }

            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if let http = self.http, http.baseURL.absoluteString == "test://do-not-send.url" {
                return
            }

            if !BTAnalyticsService.eventsQueue.isEmpty {
                self.sendQueuedAnalyticsEvents(configuration: configuration)
            }
        }
    }

    // MARK: - Helpers

    /// Sends batched events to FPTI and wipes event queue
    @objc private func sendQueuedAnalyticsEvents(configuration: BTConfiguration) {
        let postParameters = createAnalyticsEvent(config: configuration, sessionID: apiClient.metadata.sessionID, events: BTAnalyticsService.eventsQueue)
        print("Fired events: \(BTAnalyticsService.eventsQueue.map({$0.eventName}))")
        http?.post("v1/tracking/batch/events", parameters: postParameters) { _, _, _ in }
        BTAnalyticsService.eventsQueue.removeAll(keepingCapacity: true)
    }

    /// Constructs POST params to be sent to FPTI
    private func createAnalyticsEvent(config: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient.clientToken?.authorizationFingerprint,
            environment: config.fptiEnvironment,
            integrationType: apiClient.metadata.integration.stringValue,
            merchantID: config.merchantID,
            sessionID: sessionID,
            tokenizationKey: apiClient.tokenizationKey
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: events)
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.apiClient == rhs.apiClient
    }
}
