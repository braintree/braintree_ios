import Foundation

/// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Represents the metadata associated with a session for posting along with payment data during tokenization.
///
/// When a payment method is tokenized, the client api accepts parameters under
/// _meta which are used to determine where payment data originated.
///
/// In general, this data may evolve and be used in different ways by different
/// integrations in a single app. For example, if both Apple Pay and drop in are
/// used. In this case, the source and integration may change over time, while
/// the sessionID should remain constant.
@_documentation(visibility: private)
public class BTClientMetadata: Encodable {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Integration type
    public var integration: BTClientMetadataIntegration

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Integration source
    public var source: BTClientMetadataSource

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Auto-generated UUID
    public var sessionID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    public var platform = "iOS"
    
    public var version = BTCoreConstants.braintreeSDKVersion
    
    // TODO: - Remove once all POSTs moved to Codable
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
    
    private enum CodingKeys: String, CodingKey {
        case integration = "integration"
        case sessionID = "sessionId"
        case source = "source"
        case platform = "platform"
        case version = "version"
    }
    
    init(integration: BTClientMetadataIntegration = .custom, source: BTClientMetadataSource = .unknown) {
        self.integration = integration
        self.source = source
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(integration.stringValue, forKey: .integration)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(source.stringValue, forKey: .source)
        try container.encode(platform, forKey: .platform)
        try container.encode(version, forKey: .version)
    }
}
