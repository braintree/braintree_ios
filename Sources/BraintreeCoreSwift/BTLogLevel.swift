import Foundation

enum BTLogLevel: Int {
    case none, critical, error, warning, info, debug
    
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
