/// Source of the metadata
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
    
    /// String value representing the source.
    var stringValue: String {
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
