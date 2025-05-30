@testable import BraintreeCore

class MockBackgroundTaskManager: BackgroundTaskManaging {
    
    var didBeginBackgroundTask = false
    var didEndBackgroundTask = false
    var lastTaskName: String?
    var expirationHandler: (() -> Void)?
    var endedTaskID: UIBackgroundTaskIdentifier?
    var endedTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    var begunTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    var taskIDsToReturn: Set<UIBackgroundTaskIdentifier> = []
    
    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        didBeginBackgroundTask = true
        lastTaskName = named
        
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
