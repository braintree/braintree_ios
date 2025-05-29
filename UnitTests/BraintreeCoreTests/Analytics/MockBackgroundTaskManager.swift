@testable import BraintreeCore

class MockBackgroundTaskManager: BackgroundTaskManaging {
    
    var didBeginBackgroundTask = false
    var didEndBackgroundTask = false
    var lastTaskName: String?
    var expirationHandler: (@MainActor @Sendable () -> Void)?
    var endedTaskID: UIBackgroundTaskIdentifier?
    var endedTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    var begunTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    var taskIDsToReturn: Set<UIBackgroundTaskIdentifier> = []
    
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (@MainActor @Sendable () -> Void)?) -> UIBackgroundTaskIdentifier {
        didBeginBackgroundTask = true
        lastTaskName = taskName
        
        // Simulate expiration handler call
        self.expirationHandler = handler
        let id = taskIDsToReturn.isEmpty ? .invalid : taskIDsToReturn.removeFirst()
        begunTaskIDs.insert(id)
        return id
    }

    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        didEndBackgroundTask = true
        endedTaskID = identifier
        endedTaskIDs.insert(identifier)
    }
}
