import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""

    override func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        payPalContextID: String? = nil,
        linkType: String? = nil
    ) {
        self.lastEvent = eventName
    }
}
