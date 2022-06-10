import Foundation

///  Braintree leveled logger
@objcMembers public class BTLogger: NSObject {
    
    var level: BTLogLevel = .info
    var message: String?
    
    private init(logLevel: BTLogLevel) {
        level = logLevel
        super.init()
    }
    
    public func log(_ message: String) {
        log(level: level, message: message)
    }
    
    public func critical(_ message: String) {
        log(level: .critical, message: message)
    }
    
    public func error(_ message: String) {
        log(level: .error, message: message)
    }
    
    public func warning(_ message: String) {
        log(level: .warning, message: message)
    }
    
    public func info(_ message: String) {
        log(level: .info, message: message)
    }
    
    public func debug(_ message: String) {
        log(level: .debug, message: message)
    }
    
    private func log(level: BTLogLevel = .info, message: String) {
        self.message = message
        NSLog("[BraintreeSDK] %@ %@", level.description?.uppercased() ?? "", message)
    }
}
