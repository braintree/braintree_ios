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
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool = true) {
        Task(priority: .background) {
            if sendImmediately {
                print("🆕 * 12345 event \(event.eventName) to be send")
                await performEventRequestImmediatly(with: event)
            } else {
                print("🥶 1234 event \(event.eventName) to be send")
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
    
    func performEventRequestImmediatly(with event: FPTIBatchData.Event) async {
        guard let apiClient else {
            print("🫀 12345 APIClient doesnt exist \(event.eventName)")
            return
        }
        
        do {
            let configuration = try await apiClient.fetchConfiguration()
            
            let postParameters = createAnalyticsEvent(
                config: configuration,
                sessionID: apiClient.metadata.sessionID,
                events: [event]
            )
            
            _ = try? await http?.post("v1/tracking/batch/events", parameters: postParameters)
            print("🚀 * 12345 event \(event.eventName) sent")
        } catch {
            print("🛰️ 12345 get config failed")
            return
        }
    }

    // MARK: - Private Methods

    private func sendQueuedAnalyticsEvents() async {
        if await !events.isEmpty, let apiClient {
            do {
                let configuration = try await apiClient.fetchConfiguration()
                
                for (sessionID, eventsPerSessionID) in await events.allValues {
                    let postParameters = createAnalyticsEvent(
                        config: configuration,
                        sessionID: sessionID,
                        events: eventsPerSessionID
                    )
                    
                    _ = try? await http?.post("v1/tracking/batch/events", parameters: postParameters)
                    print("🥳 _ 1234 event \(eventsPerSessionID.compactMap { $0.endpoint }) sent")
                    await events.removeFor(sessionID: sessionID)
                }
            } catch {
                print("🛰️ 12345 get config failed (Queue)")
                return
            }
        } else {
            if apiClient == nil {
                print("💀 1234 APIClient doesnt exist (Queue)")
            }
        }
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
