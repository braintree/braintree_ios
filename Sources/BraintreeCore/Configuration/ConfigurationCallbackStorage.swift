import Foundation

/// Used to store, access, and manage an array of to-be-invoked `BTConfiguration` GET result callbacks in a thread-safe manner
class ConfigurationCallbackStorage {
    
    private let queue = DispatchQueue(label: "com.braintreepayments.ConfigurationCallbackStorage")
    private var pendingCompletions: [(BTConfiguration?, Error?) -> Void] = []
    
    /// The number of completions that are waiting to be invoked
    var count: Int {
        queue.sync { pendingCompletions.count }
    }
    
    /// Adds a pending, yet to-be-invoked completion handler
    func add(_ completion: @escaping (BTConfiguration?, Error?) -> Void) {
        queue.sync { pendingCompletions.append(completion) }
    }
    
    /// Executes and clears all pending completion handlers
    func invoke(_ configuration: BTConfiguration?, _ error: Error?) {
        queue.sync {
            pendingCompletions.forEach { $0(configuration, error) }
            pendingCompletions.removeAll()
        }
    }
}
