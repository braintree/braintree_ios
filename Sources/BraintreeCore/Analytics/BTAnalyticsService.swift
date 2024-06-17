import Foundation

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api.paypal.com")!

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?

    /// Exposed for testing only
    var shouldBypassTimerQueue = false

    // MARK: - Private Properties

    private static let events = BTAnalyticsEventsStorage()

    private let apiClient: BTAPIClient
    /// Amount of time, in seconds, between batch API requests sent to FPTI
    private let timerInterval = 15

    private static var timer: DispatchSourceTimer?
    
    // MARK: - Initializer

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Deinit

    deinit {
        BTAnalyticsService.timer?.cancel()
        BTAnalyticsService.timer = nil
    }

    // MARK: - Internal Methods
    
    /// Sends analytics event to https://api.paypal.com/v1/tracking/batch/events/ via a background task.
    /// - Parameters:
    ///   - eventName: Name of analytic event.
    ///   - correlationID: Optional. CorrelationID associated with the checkout session.
    ///   - endpoint: Optional. The endpoint of the API request send during networking requests.
    ///   - endTime: Optional. The end time of the roundtrip networking request.
    ///   - errorDescription: Optional. Full error description returned to merchant.
    ///   - isVaultRequest: Optional. If the Venmo or PayPal request is being vaulted.
    ///   - linkType: Optional. The type of link the SDK will be handling, currently deeplink or universal.
    ///   - payPalContextID: Optional. PayPal Context ID associated with the checkout session.
    ///   - startTime: Optional. The start time of the networking request.
    func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        endpoint: String? = nil,
        endTime: Int? = nil,
        errorDescription: String? = nil,
        isVaultRequest: Bool? = nil,
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
                isVaultRequest: isVaultRequest,
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
        isVaultRequest: Bool? = nil,
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
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID,
            startTime: startTime,
            timestamp: String(timestampInMilliseconds)
        )

        await BTAnalyticsService.events.append(event)
        
        // TODO: - Refactor to make HTTP non-optional property and instantiate in init()
        if self.http == nil {
            self.http = BTHTTP(authorization: self.apiClient.authorization, customBaseURL: BTAnalyticsService.url)
        }
        
        // A special value passed in by unit tests to prevent BTHTTP from actually posting
        if let http = self.http, http.customBaseURL?.absoluteString == "test://do-not-send.url" {
            return
        }
        
        if shouldBypassTimerQueue {
            await self.sendQueuedAnalyticsEvents()
            return
        }
        
        if BTAnalyticsService.timer == nil {
            BTAnalyticsService.timer = DispatchSource.makeTimerSource(queue: self.http?.dispatchQueue)
            BTAnalyticsService.timer?.schedule(
                deadline: .now() + .seconds(self.timerInterval),
                repeating: .seconds(self.timerInterval),
                leeway: .seconds(1)
            )
            
            BTAnalyticsService.timer?.setEventHandler {
                Task {
                    await self.sendQueuedAnalyticsEvents()
                }
            }
            
            BTAnalyticsService.timer?.resume()
        }
    }

    // MARK: - Helpers

    func sendQueuedAnalyticsEvents() async {
        if await !BTAnalyticsService.events.isEmpty {
            do {
                let configuration = try await apiClient.fetchConfiguration()
                let postParameters = await createAnalyticsEvent(config: configuration, sessionID: apiClient.metadata.sessionID, events: BTAnalyticsService.events.allValues)
                http?.post("v1/tracking/batch/events", parameters: postParameters) { _, _, _ in }
                await BTAnalyticsService.events.removeAll()
            } catch {
                return
            }
        }
    }

    /// Constructs POST params to be sent to FPTI
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient.authorization.type == .clientToken ? apiClient.authorization.bearer : nil,
            environment: config.fptiEnvironment,
            integrationType: apiClient.metadata.integration.stringValue,
            merchantID: config.merchantID,
            sessionID: sessionID,
            tokenizationKey: apiClient.authorization.type == .tokenizationKey ? apiClient.authorization.originalValue : nil
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: events)
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.apiClient == rhs.apiClient
    }
}
