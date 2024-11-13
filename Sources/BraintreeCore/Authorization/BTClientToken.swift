import Foundation

/// An authorization string used to initialize the Braintree SDK
class BTClientToken: ClientAuthorization {

    // MARK: - Internal Properties

    /// The client token as a BTJSON object
    let json: BTJSON

    /// The extracted authorization fingerprint
    let bearer: String

    /// The extracted configURL
    let configURL: URL

    let type = AuthorizationType.clientToken

    /// The original string used to initialize this instance
    let originalValue: String

    // MARK: - Initializers

    /// Initialize a client token with a client token string generated by a Braintree Server Library.
    /// - Parameter clientToken: A client token string generated by a Braintree Server Library
    init(clientToken: String) throws {
        // Client token must be decoded first because the other values are retrieved from it
        self.json = try Self.decodeClientToken(clientToken)
        
        guard let authorizationFingerprint = json["authorizationFingerprint"].asString(), !authorizationFingerprint.isEmpty else {
            throw BTClientTokenError.invalidAuthorizationFingerprint
        }
        
        guard let configURL = json["configUrl"].asURL() else {
            throw BTClientTokenError.invalidConfigURL
        }
        
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
}
