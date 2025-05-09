import Foundation

final class BTAnalyticsService: AnalyticsSendable {

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
    private let timer = RepeatingTimer()

    private var apiClient: BTAPIClient?
            
    // MARK: - Initializer
    
    private init() { }
    
    /// Used to inject `BTAPIClient` dependency into `BTAnalyticsService` singleton
    func setAPIClient(_ apiClient: BTAPIClient) {
        self.apiClient = apiClient
        self.http = BTHTTP(authorization: apiClient.authorization, customBaseURL: Self.url)
        
        timer.eventHandler = { [weak self] in
            guard let self else { return }
            Task {
                await self.sendQueuedAnalyticsEvents()
            }
        }

        timer.resume()
    }

    // MARK: - Deinit

    deinit {
        timer.suspend()
    }

    // MARK: - Internal Methods
    
    /// Sends analytics event to https://api.paypal.com/v1/tracking/batch/events/ via a background task.
    /// - Parameter event: A single `FPTIBatchData.Event`
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool) {
        Task(priority: .background) {
            if sendImmediately {
                await sendAnalyticsEvents(with: event)
            } else {
                await performEventRequest(with: event)
            }
        }
    }
    
    /// Exposed to be able to execute this function synchronously in unit tests
    func performEventRequest(with event: FPTIBatchData.Event) async {
        if let apiClient {
            await events.append(event, sessionID: apiClient.metadata.sessionID)
        }
        
        if shouldBypassTimerQueue {
            await self.sendQueuedAnalyticsEvents()
        }
    }
    
    /// Exposed for testing only
    func sendAnalyticsEvents(with event: FPTIBatchData.Event) async {
        guard let apiClient else { return }
     
        do {
            let configuration = try await apiClient.fetchConfiguration()
            try await postAnalyticsEvents(
                configuration: configuration,
                sessionID: apiClient.metadata.sessionID,
                events: [event]
            )
        } catch {
            NSLog("[BT SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods

    private func sendQueuedAnalyticsEvents() async {
        guard await !events.isEmpty, let apiClient else { return }
        
        do {
            let configuration = try await apiClient.fetchConfiguration()
            
            for (sessionID, eventsPerSessionID) in await events.allValues {
                try await postAnalyticsEvents(
                    configuration: configuration,
                    sessionID: sessionID,
                    events: eventsPerSessionID)
                await events.removeFor(sessionID: sessionID)
            }
        } catch {
            NSLog("[BT SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
    
    /// Posts analytics events to the endpoint.
    private func postAnalyticsEvents(configuration: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) async throws {
        let payload = createAnalyticsEvent(
            config: configuration,
            sessionID: sessionID,
            events: events
        )

        _ = try await http?.post("v1/tracking/batch/events", parameters: payload)
    }

    /// Constructs POST params to be sent to FPTI
    private func createAnalyticsEvent(config: BTConfiguration, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
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
