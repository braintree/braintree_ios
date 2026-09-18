import Foundation
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

    /// Raw call counts. `begunTaskIDs` and `endedTaskIDs` are `Set`s, so they cannot reveal the same
    /// identifier being begun or ended twice — these counters can.
    public var beginCallCount = 0
    public var endCallCount = 0

    private let lock = NSLock()

    /// `true` between a `beginBackgroundTask` and its matching `endBackgroundTask`. Both counts are read
    /// under a single lock acquisition so the pair cannot be observed mid-update.
    public var hasActiveTask: Bool {
        lock.withLock { beginCallCount > endCallCount }
    }

    public init() { }

    public func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        lock.lock()
        defer { lock.unlock() }

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
        lock.lock()
        defer { lock.unlock() }

        didEndBackgroundTask = true
        endCallCount += 1
        endedTaskID = identifier
        endedTaskIDs.insert(identifier)
    }
}
