import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""
    var didLastFlush: Bool = false

    override func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        payPalContextID: String? = nil,
        linkType: String? = nil
    ) {
        self.lastEvent = eventName
        self.didLastFlush = false
    }

    override func sendAnalyticsEvent(
        _ eventName: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil,
        completion: @escaping (Error?) -> Void = { _ in }
    ) {
        self.lastEvent = eventName
        self.didLastFlush = true
    }
}
