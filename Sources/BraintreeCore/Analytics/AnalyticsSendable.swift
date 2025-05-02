/// Describes a class that batches and sends analytics events.
/// - Note: Specifically created to mock the `BTAnalyticsService` singleton.
protocol AnalyticsSendable: AnyObject {
    
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool)
    func setAPIClient(_ apiClient: BTAPIClient)
}

extension AnalyticsSendable {
    
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool = true) {
        sendAnalyticsEvent(event, sendImmediately: sendImmediately)
    }
}
