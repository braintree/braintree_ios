import Foundation

/// Log level used to add formatted string to NSLog
// NEXT_MAJOR_VERSION (v7): when all modules are converted to Swift, we should used a var on this enum for the description vs using a separate class as a wrapper for Obj-C compatibility
// NEXT_MAJOR_VERSION (v7): use Foundations Logger instead of NSLog once all modules are in Swift
@objc public enum BTLogLevel: Int {
    
    /// Suppress all log output
    case none
    
    /// Only log critical issues (e.g. irrecoverable errors)
    case critical
    
    /// Log errors (e.g. expected or recoverable errors)
    case error
    
    /// Log warnings (e.g. use of pre-release features)
    case warning
    
    /// Log basic information (e.g. state changes, network activity)
    case info
    
    /// Log debugging statements (anything and everything)
    case debug
}
