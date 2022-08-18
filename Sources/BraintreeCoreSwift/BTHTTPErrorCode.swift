import Foundation

@objc public enum BTHTTPErrorCode: Int {
    /// Unknown error (reserved)
    case unknown

    /// The response had a Content-Type header that is not supported
    case responseContentTypeNotAcceptable

    /// The response was a 4xx error, e.g. 422, indicating a problem with the client's request
    case clientError

    /// The response was a 5xx server error
    case serverError

    /// The BTHTTP instance was missing a base URL
    case missingBaseURL

    /// The response was a 429, indicating a rate limiting error
    case rateLimitError

    /// The data object was unexpectedly nil
    case dataNotFound

    /// The HTTP response could not be created or is invalid
    case httpResponseInvalid

    /// The URL string is either malformed or invalid
    case urlStringInvalid
}
