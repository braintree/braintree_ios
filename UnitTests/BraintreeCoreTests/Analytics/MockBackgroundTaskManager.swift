@testable import BraintreeCore

class MockBackgroundTaskManager: BackgroundTaskManaging {
    
    var didBeginBackgroundTask = false
    var didEndBackgroundTask = false
    var lastTaskName: String?
    var lastTaskID: UIBackgroundTaskIdentifier = .invalid
    var expirationHandler: (@MainActor @Sendable () -> Void)?
    var endedTaskID: UIBackgroundTaskIdentifier?
    
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (@MainActor @Sendable () -> Void)?) -> UIBackgroundTaskIdentifier {
        didBeginBackgroundTask = true
        lastTaskName = taskName
        
        // Simulate expiration handler call
        self.expirationHandler = handler
        
        return lastTaskID
    }

    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        didEndBackgroundTask = true
        endedTaskID = identifier
    }
}
