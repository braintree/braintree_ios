import Foundation

/// Encapsulates analytics events for a given session
struct BTAnalyticsSession {

    let sessionID: String
    var events: [FPTIBatchData.Event] = []
    
    init(with sessionID: String, event: FPTIBatchData.Event) {
        self.sessionID = sessionID
        self.events = [event]
    }
}

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?
 
    var analyticsSession: BTAnalyticsSession?
    
    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api-m.paypal.com")!

    private let apiClient: BTAPIClient

    private var payPalContextID: String?

    // MARK: - Initializer

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Internal Methods

    func sendAnalyticsEvent(
        _ eventName: String,
        errorDescription: String? = nil,
        correlationID: String? = nil,
        payPalContextID: String? = nil
    ) {
        Task(priority: .background) {
            await performEventRequest(
                eventName,
                errorDescription: errorDescription,
                correlationID: correlationID,
                payPalContextID: payPalContextID
            )
        }
    }

    func performEventRequest(
        _ eventName: String,
        errorDescription: String? = nil,
        correlationID: String? = nil,
        payPalContextID: String? = nil
    ) async {
        self.payPalContextID = payPalContextID
        
        let timestampInMilliseconds = UInt64(Date().timeIntervalSince1970 * 1000)
        let event = FPTIBatchData.Event(
            correlationID: correlationID,
            errorDescription: errorDescription,
            eventName: eventName,
            timestamp: String(timestampInMilliseconds)
        )
        
        self.analyticsSession = BTAnalyticsSession(with: apiClient.metadata.sessionID, event: event)
        
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

            let postParameters = self.createAnalyticsEvent(config: configuration, sessionID: self.analyticsSession!.sessionID)
            self.http?.post("v1/tracking/batch/events", parameters: postParameters, completion: { _,_,_ in })
        }
    }

    // MARK: - Helpers

    /// Constructs POST params to be sent to FPTI from the queued events in the session
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient.clientToken?.authorizationFingerprint,
            environment: config.fptiEnvironment,
            integrationType: apiClient.metadata.integration.stringValue,
            merchantID: config.merchantID,
            payPalContextID: payPalContextID,
            sessionID: sessionID,
            tokenizationKey: apiClient.tokenizationKey
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: analyticsSession!.events)
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.apiClient == rhs.apiClient
    }
}
