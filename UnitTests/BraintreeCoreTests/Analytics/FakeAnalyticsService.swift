import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: AnalyticsSendable {
    
    var lastEvent: String? = nil
    var endpoint: String? = nil
    
    func setAPIClient(_ apiClient: BraintreeCore.BTAPIClient) {
        // No-Op
    }

    func sendAnalyticsEvent(_ event: FPTIBatchData.Event, sendImmediately: Bool = true) {
        self.lastEvent = event.eventName
        self.endpoint = event.endpoint
    }
}
