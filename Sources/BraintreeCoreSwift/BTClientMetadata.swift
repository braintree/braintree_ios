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
@objcMembers public class BTClientMetadata: NSObject, NSMutableCopying {
    
    /// Integration type
    public var integration: BTClientMetadataIntegration
    
    /// Integration source
    public var source: BTClientMetadataSource
    
    /// Auto-generated UUID
    public var sessionID: String
    
    /// String representation of the integration
    public var integrationString: String {
        integration.stringValue
    }
    
    /// String representation of the source
    public var sourceString: String {
        source.stringValue
    }
    
    /// Additional metadata parameters
    public var parameters: [String: Any] {
        [
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
    
    /// Create a copy as `BTMutableClientMetadata`
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let result = BTMutableClientMetadata()
        result.integration = self.integration
        result.source = self.source
        result.sessionID = self.sessionID
        return result
    }
    
    /// Creates a copy of `BTClientMetadata`
    @objc(copyWithZone:)
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = BTClientMetadata()
        result.integration = self.integration
        result.source = self.source
        result.sessionID = self.sessionID
        return result
    }
}
