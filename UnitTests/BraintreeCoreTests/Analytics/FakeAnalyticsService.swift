import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""
    var didLastFlush: Bool = false

    override func sendAnalyticsEvent(_ eventName: String, errorDescription: String? = nil, correlationID: String? = nil) {
        self.lastEvent = eventName
        self.didLastFlush = false
    }

    override func sendAnalyticsEvent(
        _ eventName: String,
        errorDescription: String? = nil,
        correlationID: String? = nil,
        completion: @escaping (Error?) -> Void = { _ in }
    ) {
        self.lastEvent = eventName
        self.didLastFlush = true
    }
}
