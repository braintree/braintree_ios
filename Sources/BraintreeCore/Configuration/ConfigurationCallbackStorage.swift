import Foundation

// TODO: - Do we still need this class? It no-longer wraps an array to provide thread-safety

/// Used to store, access, and manage an array of to-be-invoked `BTConfiguration` GET result callbacks
class ConfigurationCallbackStorage {
    
    // TODO: - Remove. Not an option to store array of completions.
    private var pendingCompletions: [(BTConfiguration?, Error?) -> Void] = []
    
    /// The number of completions that are waiting to be invoked
    var count: Int {
        pendingCompletions.count
    }
    
    /// Adds a pending, yet to-be-invoked completion handler
    func add(_ completion: @escaping (BTConfiguration?, Error?) -> Void) {
        pendingCompletions.append(completion)
    }
    
    /// Executes and clears all pending completion handlers
    func invoke(_ configuration: BTConfiguration?, _ error: Error?) {
        pendingCompletions.forEach { $0(configuration, error) }
        pendingCompletions.removeAll()
    }
}
