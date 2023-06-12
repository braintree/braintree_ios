/// :nodoc: This enum is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// Source of the metadata
@_documentation(visibility: private)
@objc public enum BTClientMetadataSource: Int {
    
    /// Unknown source
    case unknown
    
    /// PayPal app
    case payPalApp
    
    /// PayPal browser
    case payPalBrowser
    
    /// Venmo app
    case venmoApp
    
    /// Form
    case form

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// String value representing the source.
    public var stringValue: String {
        switch self {
        case .unknown:
            return "unknown"
        case .form:
            return "form"
        case .payPalApp:
            return "paypal-app"
        case .payPalBrowser:
            return "paypal-browser"
        case .venmoApp:
            return "venmo-app"
        }
    }
}
