import Foundation

// TODO: when all modules are converted to Swift, we should used a var on this enum for the description vs using a separate class as a wrapper for Obj-C compatibility
// TODO: use Foundations Logger instead of NSLog once all modules are in Swift
/// :nodoc: This enum is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// Log level used to add formatted string to NSLog
@_documentation(visibility: private)
public enum BTLogLevel: Int {

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
