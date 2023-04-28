/// Integration Types
@objc public enum BTClientMetadataIntegration: Int {
    /// Custom
    case custom
    
    /// Drop-in
    case dropIn
    
    /// String value representing the integration.
    var stringValue: String {
        switch self {
        case .custom:
            return "custom"
        case .dropIn:
            return "dropin"
        }
    }
}
