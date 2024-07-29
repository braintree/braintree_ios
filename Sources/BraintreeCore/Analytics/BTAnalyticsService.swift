import Foundation

class BTAnalyticsService: AnalyticsSendable {

    // MARK: - Internal Properties
    
    static let shared = BTAnalyticsService()

    // swiftlint:disable force_unwrapping
    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api.paypal.com")!
    // swiftlint:enable force_unwrapping

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?

    /// Exposed for testing only
    var shouldBypassTimerQueue = false

    // MARK: - Private Properties
    
    private let events = BTAnalyticsEventsStorage()
    
    /// Amount of time, in seconds, between batch API requests sent to FPTI
    private static let timeInterval = 15
    
    private let timer = RepeatingTimer(timeInterval: timeInterval)

    private var apiClient: BTAPIClient?
            
    // MARK: - Initializer
    
    private init() { }
    
    /// Used to inject `BTAPIClient` dependency into `BTAnalyticsService` singleton
    func setAPIClient(_ apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.http = BTHTTP(authorization: apiClient.authorization, customBaseURL: Self.url)
        
        self.timer.eventHandler = { [weak self] in
            guard let self else { return }
            Task {
                await self.sendQueuedAnalyticsEvents()
            }
        }
        self.timer.resume()
    }

    // MARK: - Deinit

    deinit {
        self.timer.suspend()
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
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event) {
        Task(priority: .background) {
            await performEventRequest(event)
        }
    }
    
    /// Exposed to be able to execute this function synchronously in unit tests
    func performEventRequest(_ event: FPTIBatchData.Event) async {
        await events.append(event)
        
        if shouldBypassTimerQueue {
            await self.sendQueuedAnalyticsEvents()
        }
    }

    // MARK: - Helpers

    func sendQueuedAnalyticsEvents() async {
        if await !events.isEmpty, let apiClient {
            do {
                let configuration = try await apiClient.fetchConfiguration()
                let postParameters = await createAnalyticsEvent(
                    config: configuration,
                    sessionID: apiClient.metadata.sessionID,
                    events: events.allValues
                )
                http?.post("v1/tracking/batch/events", parameters: postParameters) { _, _, _ in }
                await events.removeAll()
            } catch {
                return
            }
        }
    }

    /// Constructs POST params to be sent to FPTI
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient?.authorization.type == .clientToken ? apiClient?.authorization.bearer : nil,
            environment: config.fptiEnvironment,
            integrationType: apiClient?.metadata.integration.stringValue ?? BTClientMetadataIntegration.custom.stringValue,
            merchantID: config.merchantID,
            sessionID: sessionID,
            tokenizationKey: apiClient?.authorization.type == .tokenizationKey ? apiClient?.authorization.originalValue : nil
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: events)
    }
}
