/// Describes a class that batches and sends analytics events.
/// Note: - Specifically created to be able to mock the BTAnalyticsService singleton.
protocol AnalyticsSendable: AnyObject {
    
    func sendAnalyticsEvent(_ event: FPTIBatchData.Event)
    func setAPIClient(_ apiClient: BTAPIClient)
}
