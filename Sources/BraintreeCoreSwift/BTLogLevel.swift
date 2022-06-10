import Foundation

enum BTLogLevel: Int {
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
    
    var description: String? {
        switch self {
        case .none:
            return nil
            
        case .critical:
            return "Critical"
            
        case .error:
            return "Error"
            
        case .warning:
            return "Warning"
            
        case .info:
            return "Info"
            
        case .debug:
            return "Debug"
        }
    }
}
