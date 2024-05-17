import Foundation

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?

    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api-m.paypal.com")!
    
    /// Exposed for testing only
    var shouldBypassTimerQueue = false

    // MARK: - Private Properties

    private let apiClient: BTAPIClient
    /// Amount of time, in seconds, between batch API requests sent to FPTI
    private let timerInterval = 20
    private static let events = BTAnalyticsEventsStorage()

    private var timer: DispatchSourceTimer?
    
    // MARK: - Initializer

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
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
        endpoint: String? = nil,
        endTime: Int? = nil,
        errorDescription: String? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil,
        startTime: Int? = nil
    ) {
        Task(priority: .background) {
            await performEventRequest(
                eventName,
                correlationID: correlationID,
                endpoint: endpoint,
                endTime: endTime,
                errorDescription: errorDescription,
                linkType: linkType,
                payPalContextID: payPalContextID,
                startTime: startTime
            )
        }
    }
    
    /// Exposed to be able to execute this function synchronously in unit tests
    func performEventRequest(
        _ eventName: String,
        correlationID: String? = nil,
        endpoint: String? = nil,
        endTime: Int? = nil,
        errorDescription: String? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil,
        startTime: Int? = nil
    ) async {
        let timestampInMilliseconds = Date().utcTimestampMilliseconds
        let event = FPTIBatchData.Event(
            correlationID: correlationID,
            endpoint: endpoint,
            endTime: endTime,
            errorDescription: errorDescription,
            eventName: eventName,
            linkType: linkType,
            payPalContextID: payPalContextID,
            startTime: startTime,
            timestamp: String(timestampInMilliseconds)
        )

        await BTAnalyticsService.events.append(event)
        
        do {
            let configuration = try await apiClient.fetchConfiguration()
            
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
            
            if shouldBypassTimerQueue {
                await self.sendQueuedAnalyticsEvents(configuration: configuration)
                return
            }

            if self.timer == nil {
                self.timer = DispatchSource.makeTimerSource(queue: self.http?.dispatchQueue)
                self.timer?.schedule(
                    deadline: .now() + .seconds(self.timerInterval),
                    repeating: .seconds(self.timerInterval),
                    leeway: .seconds(1)
                )

                self.timer?.setEventHandler {
                    Task {
                        await self.sendQueuedAnalyticsEvents(configuration: configuration)
                    }
                }

                self.timer?.resume()
            }
        } catch {
            return
        }
    }

    // MARK: - Helpers

    func sendQueuedAnalyticsEvents(configuration: BTConfiguration) async {
        if await !BTAnalyticsService.events.isEmpty {
            let postParameters = await createAnalyticsEvent(config: configuration, sessionID: apiClient.metadata.sessionID, events: BTAnalyticsService.events.allValues)
            http?.post("v1/tracking/batch/events", parameters: postParameters) { _, _, _ in }
            await BTAnalyticsService.events.removeAll()
        } else {
            timer?.cancel()
            timer = nil
        }
    }

    /// Constructs POST params to be sent to FPTI
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
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
