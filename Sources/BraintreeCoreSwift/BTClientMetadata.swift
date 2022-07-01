import Foundation



/// Represents the metadata associated with a session for posting along with payment data during tokenization.
///
/// When a payment method is tokenized, the client api accepts parameters under
/// _meta which are used to determine where payment data originated.
///
/// In general, this data may evolve and be used in different ways by different
/// integrations in a single app. For example, if both Apple Pay and drop in are
/// used. In this case, the source and integration may change over time, while
/// the sessionID should remain constant. To achieve this, users of this class
/// should use `mutableCopy` to create a new copy based on the existing session
/// and then update the object as needed.

@objcMembers public class BTClientMetadataSwift: NSObject {
    
    /// Integration type
    public var integration: BTClientMetadataIntegrationTypeSwift
    
    /// Integration source
    public var source: BTClientMetadataSourceTypeSwift
    
    /// Auto-generated UUID
    public var sessionID: String
    
    /// String representation of the integration
    // NEXT_MAJOR_VERSION: v7, move into enum BTClientMetadataIntegrationType
    public var integrationString: String {
        switch self.integration {
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
    
    /// String representation of the source
    // NEXT_MAJOR_VERSION: v7, move into enum BTClientMetadataSourceType
    public var sourceString: String {
        switch self.source {
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
    
    /// Additional metadata parameters
    public var parameters: [String: Any] {
        return [
            "integration": self.integrationString,
            "source": self.sourceString,
            "sessionId": self.sessionID
        ]
    }
    
    public override init() {
        self.integration = .custom
        self.source = .unknown
        self.sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        super.init()
    }
}
