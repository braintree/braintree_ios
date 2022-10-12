import Foundation

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String = ""
    var didLastFlush: Bool = false

    override func sendAnalyticsEvent(_ eventKind: String) {
        self.lastEvent = eventKind
        self.didLastFlush = false
    }

    override func sendAnalyticsEvent(_ eventKind: String, completion completionBlock: ((Error?) -> Void)? = nil) {
        self.lastEvent = eventKind
        self.didLastFlush = true
    }
}
