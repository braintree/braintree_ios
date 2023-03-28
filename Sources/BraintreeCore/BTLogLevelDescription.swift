import Foundation

/// Wrapper for accessing the string value of the log level
@objcMembers public class BTLogLevelDescription: NSObject {
    
    // TODO: - Refactor to return non-optional string
    public static func string(for level: BTLogLevel) -> String? {
        switch level {
        case .none:
            return nil
            
        case .critical:
            return "[BraintreeSDK] CRITICAL"
            
        case .error:
            return "[BraintreeSDK] ERROR"
            
        case .warning:
            return "[BraintreeSDK] WARNING"
            
        case .info:
            return "[BraintreeSDK] INFO"
            
        case .debug:
            return "[BraintreeSDK] DEBUG"
        }
    }
}
