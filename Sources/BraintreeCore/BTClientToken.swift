import Foundation

/// An authorization string used to initialize the Braintree SDK
@_documentation(visibility: private)
@objcMembers public class BTClientToken: NSObject, NSCoding, NSCopying, Authorization {
    
    // NEXT_MAJOR_VERSION (v7): properties exposed for Objective-C interoperability + Drop-in access.
    // Once the entire SDK is in Swift, determine if we want public properties to be internal and
    // what we can make internal without breaking the Drop-in.
    // MARK: - Public Properties

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The client token as a BTJSON object
    public let json: BTJSON

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The extracted authorization fingerprint
    public let authorizationFingerprint: String

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The extracted configURL
    public let configURL: URL
    
    // duplicate of authFingerprint
    public let bearer: String

    public let type = BTAPIClientAuthorization.clientToken

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The original string used to initialize this instance
    public let originalValue: String

    // MARK: - Initializers

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Initialize a client token with a client token string generated by a Braintree Server Library.
    /// - Parameter clientToken: A client token string generated by a Braintree Server Library
    @objc(initWithClientToken:error:)
    public init(clientToken: String) throws {
        // Client token must be decoded first because the other values are retrieved from it
        self.json = try Self.decodeClientToken(clientToken)
        
        guard let authorizationFingerprint = json["authorizationFingerprint"].asString(),
              !authorizationFingerprint.isEmpty else {
            throw BTClientTokenError.invalidAuthorizationFingerprint
        }
        
        guard let configURL = json["configUrl"].asURL() else {
            throw BTClientTokenError.invalidConfigURL
        }
        
        self.authorizationFingerprint = authorizationFingerprint
        self.bearer = authorizationFingerprint
        self.configURL = configURL
        self.originalValue = clientToken
    }
    
    // MARK: - Internal helper functions

    private static func decodeClientToken(_ rawClientToken: String) throws -> BTJSON {
        let data: Data
        let isBase64: Bool

        if let base64Data = Data(base64Encoded: rawClientToken) {
            data = base64Data
            isBase64 = true
        } else if let utf8Data = rawClientToken.data(using: .utf8) {
            data = utf8Data
            isBase64 = false
        } else {
            throw BTClientTokenError.failedDecoding("Base64 or UTF8 encoding is required for Client Token.")
        }

        guard let clientTokenJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BTClientTokenError.invalidFormat("Invalid JSON. Expected to find an object at JSON root.")
        }

        guard let version = clientTokenJSON["version"] as? Int else {
            throw BTClientTokenError.invalidFormat("Invalid version number. Expected to find an integer for key \"version\".")
        }

        if version == 1 && isBase64 {
            throw BTClientTokenError.failedDecoding("UTF8 encoding is required for Client Token version 1.")
        } else if (version == 2 || version == 3) && !isBase64 {
            throw BTClientTokenError.failedDecoding("Base64 encoding is required for Client Token versions 2 & 3.")
        } else if version < 1 || version > 3 {
            throw BTClientTokenError.unsupportedVersion
        }

        return BTJSON(value: clientTokenJSON)
    }

    // MARK: - NSCoding conformance

    public func encode(with coder: NSCoder) {
        coder.encode(originalValue, forKey: "originalValue")
    }

    public required convenience init?(coder: NSCoder) {
        try? self.init(
            clientToken: coder.decodeObject(forKey: "originalValue") as? String ?? ""
        )
    }

    // MARK: - NSCopying conformance

    @objc(copyWithZone:)
    public func copy(with zone: NSZone? = nil) -> Any {
        do {
            return try BTClientToken(clientToken: self.originalValue)
        } catch {
            return error
        }
    }

    // MARK: - NSObject override

    public override func isEqual(_ object: Any?) -> Bool {
        guard object is BTClientToken,
              let otherToken = object as? BTClientToken else {
            return false
        }

        return self.json.asDictionary() == otherToken.json.asDictionary()
    }
}
