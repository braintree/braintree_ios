/// Integration Types
@objc public enum BTClientMetadataIntegration: Int {
    /// Custom
    case custom
    
    /// Drop-in
    case dropIn
    
    /// Drop-in 2
    case dropIn2
    
    /// Unknown Integration
    case unknown
    
    /// String value representing the integration.
    var stringValue: String {
        switch self {
        case .unknown:
            return "unknown"
        case .dropIn:
            return "dropin"
        case .dropIn2:
            return "dropin2"
        case .custom:
            return "custom"
        }
    }
}
