import Foundation

///  :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
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
@_documentation(visibility: private)
@objcMembers public class BTClientMetadata: NSObject, NSCopying {

    ///  :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Integration type
    @_documentation(visibility: private)
    public var integration: BTClientMetadataIntegration

    ///  :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Integration source
    @_documentation(visibility: private)
    public var source: BTClientMetadataSource

    ///  :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Auto-generated UUID
    @_documentation(visibility: private)
    public var sessionID: String
    
    /// Additional metadata parameters
    var parameters: [String: Any] {
        [
            "integration": integration.stringValue,
            "source": source.stringValue,
            "sessionId": sessionID,
            "platform": "iOS",
            "version": BTCoreConstants.braintreeSDKVersion
        ]
    }
    
    override init() {
        self.integration = .custom
        self.source = .unknown
        self.sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        super.init()
    }

    ///  :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Creates a copy of `BTClientMetadata`
    @_documentation(visibility: private)
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = BTClientMetadata()
        result.integration = self.integration
        result.source = self.source
        result.sessionID = self.sessionID
        return result
    }
}
