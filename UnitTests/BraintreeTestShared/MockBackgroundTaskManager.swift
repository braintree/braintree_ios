import UIKit
@testable import BraintreeCore

/// Test double for `BackgroundTaskManaging`.
///
/// Every property is guarded by `lock`, because `BTAnalyticsService_Tests` drives this mock from several
/// concurrent `Task`s and `BTAnalyticsService` performs no synchronization of its own. Mutating the `Set`
/// properties from more than one thread corrupts their copy-on-write storage, which surfaces as heap
/// corruption — for example `-[__NSTaggedDate member:]: unrecognized selector sent to instance 0x8000000000000000`,
/// where set storage has been freed and the `member:` membership call lands on whatever now occupies that
/// memory. Holding the lock across the `isEmpty` / `removeFirst()` pair in `beginBackgroundTask` also makes
/// that check-then-act atomic, so two threads can no longer both pass the emptiness check and have the
/// loser trap on `removeFirst()`.
///
/// `NSLock.withLock` is iOS 16+, so locking here is manual to stay within the iOS 14 deployment target.
public class MockBackgroundTaskManager: BackgroundTaskManaging {

    private let lock = NSLock()

    // MARK: - Backing Storage

    /// Access only while holding `lock`.
    private var _didBeginBackgroundTask = false
    private var _didEndBackgroundTask = false
    private var _lastTaskName: String?
    private var _expirationHandler: (() -> Void)?
    private var _endedTaskID: UIBackgroundTaskIdentifier?
    private var _endedTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    private var _begunTaskIDs: Set<UIBackgroundTaskIdentifier> = []
    private var _taskIDsToReturn: Set<UIBackgroundTaskIdentifier> = []
    private var _beginCallCount = 0
    private var _endCallCount = 0

    // MARK: - Synchronized Accessors

    public var didBeginBackgroundTask: Bool {
        get { synchronized { _didBeginBackgroundTask } }
        set { synchronized { _didBeginBackgroundTask = newValue } }
    }

    public var didEndBackgroundTask: Bool {
        get { synchronized { _didEndBackgroundTask } }
        set { synchronized { _didEndBackgroundTask = newValue } }
    }

    public var lastTaskName: String? {
        get { synchronized { _lastTaskName } }
        set { synchronized { _lastTaskName = newValue } }
    }

    public var expirationHandler: (() -> Void)? {
        get { synchronized { _expirationHandler } }
        set { synchronized { _expirationHandler = newValue } }
    }

    public var endedTaskID: UIBackgroundTaskIdentifier? {
        get { synchronized { _endedTaskID } }
        set { synchronized { _endedTaskID = newValue } }
    }

    public var endedTaskIDs: Set<UIBackgroundTaskIdentifier> {
        get { synchronized { _endedTaskIDs } }
        set { synchronized { _endedTaskIDs = newValue } }
    }

    public var begunTaskIDs: Set<UIBackgroundTaskIdentifier> {
        get { synchronized { _begunTaskIDs } }
        set { synchronized { _begunTaskIDs = newValue } }
    }

    public var taskIDsToReturn: Set<UIBackgroundTaskIdentifier> {
        get { synchronized { _taskIDsToReturn } }
        set { synchronized { _taskIDsToReturn = newValue } }
    }

    /// Raw call counts. `endedTaskIDs` is a `Set`, so it cannot reveal the same identifier being
    /// ended twice — these counters can.
    public var beginCallCount: Int {
        get { synchronized { _beginCallCount } }
        set { synchronized { _beginCallCount = newValue } }
    }

    public var endCallCount: Int {
        get { synchronized { _endCallCount } }
        set { synchronized { _endCallCount = newValue } }
    }

    /// `true` between a `beginBackgroundTask` and its matching `endBackgroundTask`. Both counts are read
    /// under a single lock acquisition so the pair cannot be observed mid-update.
    public var hasActiveTask: Bool {
        synchronized { _beginCallCount > _endCallCount }
    }

    public init() { }

    // MARK: - BackgroundTaskManaging

    public func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        lock.lock()
        defer { lock.unlock() }

        _didBeginBackgroundTask = true
        _beginCallCount += 1
        _lastTaskName = named

        // Retained so a test can simulate expiration on demand.
        _expirationHandler = handler
        let id = _taskIDsToReturn.isEmpty ? .invalid : _taskIDsToReturn.removeFirst()
        _begunTaskIDs.insert(id)
        return id
    }

    public func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        lock.lock()
        defer { lock.unlock() }

        _didEndBackgroundTask = true
        _endCallCount += 1
        _endedTaskID = identifier
        _endedTaskIDs.insert(identifier)
    }

    // MARK: - Test Helpers

    /// Simulates iOS calling the expiration handler shortly before background time reaches 0.
    ///
    /// The handler is read out and then invoked with the lock released. Handlers typically call back into
    /// `endBackgroundTask`, and `NSLock` is not recursive, so invoking while holding the lock would deadlock.
    public func simulateExpiration() {
        let handler = expirationHandler
        handler?()
    }

    // MARK: - Private Methods

    private func synchronized<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
