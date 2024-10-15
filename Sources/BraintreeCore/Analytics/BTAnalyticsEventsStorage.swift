import Foundation

/// Used to store and access our dictionary of events in a thread-safe manner
actor BTAnalyticsEventsStorage {

    // A list of analytic events, keyed by sessionID
    private var events: [String: [FPTIBatchData.Event]]

    var isEmpty: Bool {
        events.isEmpty
    }

    var allValues: [String: [FPTIBatchData.Event]] {
        events
    }

    init() {
        self.events = [:]
    }

    func append(_ event: FPTIBatchData.Event, sessionID: String) {
        events[sessionID] = (events[sessionID] ?? []) + [event]
    }
    
    func removeFor(sessionID: String) {
        events.removeValue(forKey: sessionID)
    }
}
