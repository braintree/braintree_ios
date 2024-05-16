import Foundation

actor BTAnalyticsEventsStorage {

    private var events: [FPTIBatchData.Event]

    var isEmpty: Bool {
        events.isEmpty
    }

    var allValues: [FPTIBatchData.Event] {
        events
    }

    init() {
        self.events = []
    }

    func append(_ event: FPTIBatchData.Event) {
        events.append(event)
    }

    func removeAll() {
        events.removeAll()
    }
}
