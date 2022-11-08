import Foundation
@testable import BraintreeCoreSwift

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""
    var didLastFlush: Bool = false

    override func sendAnalyticsEvent(_ eventName: String) {
        self.lastEvent = eventName
        self.didLastFlush = false
    }

    override func sendAnalyticsEvent(_ eventName: String, completion completionBlock: ((Error?) -> Void)? = nil) {
        self.lastEvent = eventName
        self.didLastFlush = true
    }
}
