import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String? = nil
    var endpoint: String? = nil

    override func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        endpoint: String? = nil,
        endTime: Int? = nil,
        errorDescription: String? = nil,
        isVaultRequest: Bool? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil,
        startTime: Int? = nil
    ) {
        self.lastEvent = eventName
        self.endpoint = endpoint
    }
}
