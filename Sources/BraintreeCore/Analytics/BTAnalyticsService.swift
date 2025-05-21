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

    // MARK: - Private Properties
    
    private let events = BTAnalyticsEventsStorage()
    private let timer = RepeatingTimer()

    private var apiClient: BTAPIClient?
            
    // MARK: - Initializer
    
    private init() { }
    
    /// Used to inject `BTAPIClient` dependency into `BTAnalyticsService` singleton
    func setAPIClient(_ apiClient: BTAPIClient) {
        let instance = Unmanaged.passUnretained(apiClient).toOpaque()
        print("👀 12345 Analytics set APIClient \(instance)")
        
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
        let instance = Unmanaged.passUnretained(self).toOpaque()
        print("🚨 12345 Analytics deinit \(instance)")
        timer.suspend()
    }

    // MARK: - Internal Methods
    
    /// Sends analytics event to https://api.paypal.com/v1/tracking/batch/events/ via a background task.
    /// - Parameter event: A single `FPTIBatchData.Event`
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool) {
        Task(priority: .background) {
            sendImmediately ? sendAnalyticsEventsImmediately(event: event) : await performEventRequest(with: event)
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
    func sendAnalyticsEventsImmediately(event: FPTIBatchData.Event) {
        guard let apiClient else {
            print("🫀 12345 APIClient doesnt exist \(event.eventName)")
            return
        }
        
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

        // Begin a background task to give the app extra time to complete the network request,
        // even if it moves to the background. The closure passed here is the expirationHandler.
        //
        // The expirationHandler is called if the system’s maximum background execution time
        // (typically around 30 seconds) is reached before the task completes.
        // If we don't explicitly end the task here, the app may be forcefully terminated by the system.
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "BTSendAnalyticEvent") {
            // We end the task here to avoid the app being terminated.
            print("👟 12345 Background Task ID Deinit RawValue \(backgroundTaskID.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        print("👟 12345 Background Task ID Init RawValue \(backgroundTaskID.rawValue)")
        
        sendAnalyticEvent(event, apiClient: apiClient, identifier: backgroundTaskID) {
            // Explicitly end the background task after the work is completed
            print("👟 12345 Background Task Finish RawValue \(backgroundTaskID.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    /// Exposed to be able to execute this function synchronously in unit tests
    func sendAnalyticEvent(_ event: FPTIBatchData.Event, apiClient: BTAPIClient, identifier: UIBackgroundTaskIdentifier, completion: @escaping () -> Void) {
        Task {
            do {
                if event.eventName == "paypal:tokenize:app-switch:succeeded" {
                    print("❄️ 12345 app switch identifier \(identifier.rawValue)")
                    try? await Task.sleep(nanoseconds: 40 * 1_000_000_000)
                } else {
                    let configuration = try await apiClient.fetchConfiguration()
                    try await postAnalyticsEvents(
                        configuration: configuration,
                        sessionID: apiClient.metadata.sessionID,
                        events: [event]
                    )
                }
                print("🚀 * 12345 event \(event.eventName) sent")
                print("🥈 12345 End Time \(Date().utcTimestampMilliseconds) \(event.eventName)")
                completion()
            } catch {
                print("🛰️ 12345 get config failed")
                NSLog("[BT SDK] Failed to send analytics: %@", error.localizedDescription)
                NSLog("[BT SDK] Failed to send analytics: %@", error.localizedDescription)
                completion()
            }
        }
    }

    // MARK: - Private Methods

    private func sendQueuedAnalyticsEvents() async {
        guard await !events.isEmpty, let apiClient else {
            if apiClient == nil {
                print("💀 1234 APIClient doesnt exist (Queue)")
            }
            return
        }
        
        do {
            let configuration = try await apiClient.fetchConfiguration()
            
            for (sessionID, eventsPerSessionID) in await events.allValues {
                try await postAnalyticsEvents(
                    configuration: configuration,
                    sessionID: sessionID,
                    events: eventsPerSessionID
                )
                print("🥳 _ 1234 event \(eventsPerSessionID.compactMap { $0.endpoint }) sent")
                await events.removeFor(sessionID: sessionID)
            }
        } catch {
            print("🛰️ 12345 get config failed (Queue)")
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
