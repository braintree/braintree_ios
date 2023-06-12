/// :nodoc: This enum is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// Integration Types
@_documentation(visibility: private)
@objc public enum BTClientMetadataIntegration: Int {
    /// Custom
    case custom
    
    /// Drop-in
    case dropIn

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// String value representing the integration.
    public var stringValue: String {
        switch self {
        case .custom:
            return "custom"
        case .dropIn:
            return "dropin"
        }
    }
}
