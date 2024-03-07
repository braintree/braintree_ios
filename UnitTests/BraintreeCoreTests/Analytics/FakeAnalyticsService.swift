import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""

    override func sendAnalyticsEvent(
        _ eventName: String,
        errorDescription: String? = nil,
        correlationID: String? = nil,
        payPalContextID: String? = nil
    ) {
        self.lastEvent = eventName
    }
}
