import UIKit
@testable import BraintreeCore

public class MockBackgroundTaskManager: BackgroundTaskManaging {

    public var didBeginBackgroundTask = false
    public var didEndBackgroundTask = false
    public var lastTaskName: String?
    public var expirationHandler: (() -> Void)?
    public var endedTaskID: UIBackgroundTaskIdentifier?
    public var endedTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    public var begunTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    public var taskIDsToReturn: Set<UIBackgroundTaskIdentifier> = []

    /// Raw call counts. `endedTaskIDs` is a `Set`, so it cannot reveal the same identifier being
    /// ended twice — these counters can.
    public var beginCallCount = 0
    public var endCallCount = 0

    /// `true` between a `beginBackgroundTask` and its matching `endBackgroundTask`.
    public var hasActiveTask: Bool { beginCallCount > endCallCount }

    public init() { }

    public func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        didBeginBackgroundTask = true
        beginCallCount += 1
        lastTaskName = named

        // Simulate expiration handler call
        self.expirationHandler = handler
        let id = taskIDsToReturn.isEmpty ? .invalid : taskIDsToReturn.removeFirst()
        begunTaskIDs.insert(id)
        return id
    }

    public func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        didEndBackgroundTask = true
        endCallCount += 1
        endedTaskID = identifier
        endedTaskIDs.insert(identifier)
    }

    /// Simulates iOS calling the expiration handler shortly before background time reaches 0.
    public func simulateExpiration() {
        expirationHandler?()
    }
}
