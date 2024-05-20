import Foundation

class BTAnalyticsService: Equatable {

    // MARK: - Internal Properties

    /// The HTTP client for communication with the analytics service endpoint. Exposed for testing.
    var http: BTHTTP?
    
    /// The FPTI URL to post all analytic events.
    static let url = URL(string: "https://api-m.paypal.com")!

    private let apiClient: BTAPIClient

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

            let postParameters = self.createAnalyticsEvent(config: configuration, sessionID: self.apiClient.metadata.sessionID, event: event)
            self.http?.post("v1/tracking/batch/events", parameters: postParameters) { _, _, _ in }
        }
    }

    // MARK: - Helpers

    /// Constructs POST params to be sent to FPTI
    func createAnalyticsEvent(config: BTConfiguration, sessionID: String, event: FPTIBatchData.Event) -> Codable {
        let batchMetadata = FPTIBatchData.Metadata(
            authorizationFingerprint: apiClient.clientToken?.authorizationFingerprint,
            environment: config.fptiEnvironment,
            integrationType: apiClient.metadata.integration.stringValue,
            merchantID: config.merchantID,
            sessionID: sessionID,
            tokenizationKey: apiClient.tokenizationKey
        )
        
        return FPTIBatchData(metadata: batchMetadata, events: [event])
    }

    // MARK: Equitable Protocol Conformance

    static func == (lhs: BTAnalyticsService, rhs: BTAnalyticsService) -> Bool {
        lhs.http == rhs.http && lhs.apiClient == rhs.apiClient
    }
}
