import Foundation

@objcMembers public class BTLogger: NSObject {
    
    var level: BTLogLevel
    
    private init(logLevel: BTLogLevel) {
        level = logLevel
        super.init()
    }
    
    public func log(format: String, args: String...) {
        log(level: level, format: format, args: args)
    }
    
    public func critical(format: String, args: String...) {
        log(level: .critical, format: format, args: args)
    }
    
    public func error(format: String, args: String...) {
        log(level: .error, format: format, args: args)
    }
    
    public func warning(format: String, args: String...) {
        log(level: .warning, format: format, args: args)
    }
    
    public func info(format: String, args: String...) {
        log(level: .info, format: format, args: args)
    }
    
    public func debug(format: String, args: String...) {
        log(level: .debug, format: format, args: args)
    }
    
    private func log(level: BTLogLevel, format: String, args: [String]){
        guard level.rawValue <= self.level.rawValue else {
            return
        }
        let message = String(format: format, arguments: args)
//        if let logBlock = logBlock {
//            logBlock(level, message)
//        } else {
//            NSLog("[BraintreeSDK] %@ %@", level.description?.uppercased() ?? "", message)
//        }
    }
}
