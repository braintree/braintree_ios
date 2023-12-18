import Foundation

/// Error codes associated with BTHTTP
public enum BTHTTPError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error (reserved)
    case unknown

    /// 1. The response had a Content-Type header that is not supported
    case responseContentTypeNotAcceptable([String: Any])

    /// 2. The response was a 4xx error, e.g. 422, indicating a problem with the client's request
    case clientError([String: Any])

    /// 3. The response was a 5xx server error
    case serverError([String: Any])

    /// 4. The BTHTTP instance was missing a base URL
    case missingBaseURL([String: Any])

    /// 5. The response was a 429, indicating a rate limiting error
    case rateLimitError([String: Any])

    /// 6. The data object was unexpectedly nil
    case dataNotFound

    /// 7. The HTTP response could not be created or is invalid
    case httpResponseInvalid

    /// 8. The URL string is either malformed or invalid
    case urlStringInvalid

    /// 9. The client API URL is either malformed or invalid
    case clientApiURLInvalid

    /// 10. The authorization fingerprint is invalid
    case invalidAuthorizationFingerprint
    
    /// 11. Failed to convert `Encodable` type to `[String: Any]` dictionary
    case serializationError(String)

    /// 12. Deallocated HTTPClient
    case deallocated(String)

    public static var errorDomain: String {
        BTCoreConstants.httpErrorDomain
    }

    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .responseContentTypeNotAcceptable:
            return 1
        case .clientError:
            return 2
        case .serverError:
            return 3
        case .missingBaseURL:
            return 4
        case .rateLimitError:
            return 5
        case .dataNotFound:
            return 6
        case .httpResponseInvalid:
            return 7
        case .urlStringInvalid:
            return 8
        case .clientApiURLInvalid:
            return 9
        case .invalidAuthorizationFingerprint:
            return 10
        case .serializationError:
            return 11
        case .deallocated:
            return 12
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .unknown:
            return [NSLocalizedDescriptionKey: "An unexpected error occurred with the HTTP request."]
        case .responseContentTypeNotAcceptable(let errorDictionary):
            return ["Response content type not accepted with properties": errorDictionary]
        case .clientError(let errorDictionary):
            return errorDictionary
        case .serverError(let errorDictionary):
            return errorDictionary
        case .missingBaseURL(let errorDictionary):
            return ["Base URL constructed with invalid properties": errorDictionary]
        case .rateLimitError(let errorDictionary):
            return errorDictionary
        case .dataNotFound:
            return [NSLocalizedDescriptionKey: "Data unexpectedly nil."]
        case .httpResponseInvalid:
            return [NSLocalizedDescriptionKey: "Unable to create HTTPURLResponse from response data."]
        case .urlStringInvalid:
            return [NSLocalizedDescriptionKey: "The URL absolute string is malformed or invalid."]
        case .clientApiURLInvalid:
            return [NSLocalizedDescriptionKey: "Client API URL is not a valid URL."]
        case .invalidAuthorizationFingerprint:
            return [NSLocalizedDescriptionKey: "BTClientToken contained a nil or empty authorizationFingerprint."]
        case .serializationError(let errorDescription):
            return [NSLocalizedDescriptionKey: errorDescription]
        case .deallocated(let httpType):
            return [NSLocalizedDescriptionKey: "\(httpType) has been deallocated."]
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTHTTPError, rhs: BTHTTPError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
