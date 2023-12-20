import Foundation

///  Error codes associated with a client token.
public enum BTClientTokenError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Authorization fingerprint was not present or invalid
    case invalidAuthorizationFingerprint

    /// 1. Config URL was missing or invalid
    case invalidConfigURL

    /// 2. Invalid client token format
    case invalidFormat(String)

    /// 3. Unsupported client token version
    case unsupportedVersion
    
    /// 4. Failed decoding from Base64 or UTF8
    case failedDecoding(String)

    public static var errorDomain: String {
        "com.braintreepayments.BTClientTokenErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .invalidAuthorizationFingerprint:
            return 0
        case .invalidConfigURL:
            return 1
        case .invalidFormat:
            return 2
        case .unsupportedVersion:
            return 3
        case .failedDecoding:
            return 4
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidAuthorizationFingerprint:
            return "Invalid client token. Please ensure your server is generating a valid Braintree ClientToken. Authorization fingerprint was not present or invalid."
        case .invalidConfigURL:
            return "Invalid client token: config URL was missing or invalid. Please ensure your server is generating a valid Braintree ClientToken."
        case .invalidFormat(let description):
            return "Invalid client token format. Please ensure your server is generating a valid Braintree ClientToken. \(description)"
        case .unsupportedVersion:
            return "Unsupported client token version. Please ensure your server is generating a valid Braintree ClientToken with a server-side SDK that is compatible with this version of Braintree iOS."
        case .failedDecoding(let description):
            return "Failed to decode client token. \(description)"
        }
    }
}
