import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// Wrapper for accessing the string value of the log level
@_documentation(visibility: private)
public class BTLogLevelDescription: NSObject {
    
    public static func string(for level: BTLogLevel) -> String {
        switch level {
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
