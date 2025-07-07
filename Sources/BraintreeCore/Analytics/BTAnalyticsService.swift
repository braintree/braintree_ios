import UIKit

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
    
    /// Exposed for testing only
    var application: BackgroundTaskManaging = UIApplication.shared

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
            sendImmediately ? await sendAnalyticsEventsImmediately(event: event) : await performEventRequest(with: event)
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
    
    /// Sends a single analytics event immediately, even if the app is transitioning to the background.
    ///
    /// This method initiates a background task using `UIApplication.shared.beginBackgroundTask` to
    /// ensure that the event has enough time to be sent before the OS suspends the app.
    /// The background task is safely ended both in the expiration handler and after the event is sent.
    ///
    /// Exposed to be able to execute this function synchronously in unit tests
    func sendAnalyticsEventsImmediately(event: FPTIBatchData.Event) async {
        guard let apiClient else { return }
        
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        
        // Begin a background task to give the app extra time to complete the network request,
        // even if it moves to the background. The closure passed here is the expirationHandler.
        //
        // The expirationHandler is called if the system’s maximum background execution time
        // (typically around 30 seconds) is reached before the task completes.
        // If we don't explicitly end the task here, the app may be forcefully terminated by the system.
        backgroundTaskID = application.beginBackgroundTask(named: "BTSendAnalyticEvent") { [weak self] in
            guard let self, backgroundTaskID != .invalid else { return }
            // We end the task here to avoid the app being terminated.
            self.application.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }

        await sendAnalyticEvent(event, apiClient: apiClient)

        guard backgroundTaskID != .invalid else { return }
        // Explicitly end the background task after the work is completed
        application.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
    
    /// Exposed to be able to execute this function synchronously in unit tests
    func sendAnalyticEvent(_ event: FPTIBatchData.Event, apiClient: BTAPIClient) async {
        do {
            let configuration = try await apiClient.fetchConfiguration()
            try await postAnalyticsEvents(
                configuration: configuration,
                applicationState: UIApplication.shared.applicationState,
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
                    applicationState: UIApplication.shared.applicationState,
                    sessionID: sessionID,
                    events: eventsPerSessionID
                )
                await events.removeFor(sessionID: sessionID)
            }
        } catch {
            NSLog("[BT SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
    
    /// Posts analytics events to the endpoint.
    private func postAnalyticsEvents(configuration: BTConfiguration, applicationState: UIApplication.State, sessionID: String, events: [FPTIBatchData.Event]) async throws {
        let payload = createAnalyticsEvent(
            config: configuration,
            applicationState: applicationState,
            sessionID: sessionID,
            events: events
        )

        _ = try await http?.post("v1/tracking/batch/events", parameters: payload)
    }

    /// Constructs POST params to be sent to FPTI
    private func createAnalyticsEvent(config: BTConfiguration, applicationState: UIApplication.State, sessionID: String, events: [FPTIBatchData.Event]) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient?.authorization.type == .clientToken ? apiClient?.authorization.bearer : nil,
            environment: config.fptiEnvironment,
            integrationType: apiClient?.metadata.integration.stringValue ?? BTClientMetadataIntegration.custom.stringValue,
            merchantID: config.merchantID,
            applicationState: applicationState.asString,
            sessionID: sessionID,
            tokenizationKey: apiClient?.authorization.type == .tokenizationKey ? apiClient?.authorization.originalValue : nil
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: events)
    }
}

extension UIApplication.State {
    var asString: String {
        switch self {
        case .active: "active"
        case .inactive: "inactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }
}
