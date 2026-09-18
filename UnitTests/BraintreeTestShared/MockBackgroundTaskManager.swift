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

    /// `endedTaskIDs` is a `Set`, so it cannot reveal the same identifier being ended twice — this can.
    /// Relevant because expiry and the `defer` in `handleReturn` both call `endBackgroundTask`.
    public var endCallCount = 0

    private let lock = NSLock()

    public init() { }

    public func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        lock.lock()
        defer { lock.unlock() }

        didBeginBackgroundTask = true
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
