import Foundation

/// Error codes associated with Venmo App Switch
enum BTVenmoAppSwitchError: Error, CustomNSError, LocalizedError {

    /// The error returned from the Venmo return URL
    case returnURLError(Int, String?)

    static var errorDomain: String {
        "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .returnURLError(let errorCode, _):
            return errorCode
        }
    }

    var errorDescription: String? {
        switch self {
        case .returnURLError(_, let errorMessage):
            return errorMessage
        }
    }
}

/// Error codes associated with Venmo
enum BTVenmoError: Error, CustomNSError, LocalizedError {

    /// Venmo is not enabled
    case disabled

    /// The Venmo app is not installed or configured for app Switch
    case appNotAvailable

    /// Bundle display name is nil
    case bundleDisplayNameMissing

    /// Return URL is invalid
    case invalidReturnURL(String)

    /// No body was returned from the request
    case invalidBodyReturned

    /// App Switch could not complete
    case appSwitchFailed

    /// Invalid request URL
    case invalidRequestURL(String)

    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    static var errorDomain: String {
        "com.braintreepayments.BTVenmoErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .disabled:
            return 0
        case .appNotAvailable:
            return 1
        case .bundleDisplayNameMissing:
            return 2
        case .invalidReturnURL:
            return 3
        case .invalidBodyReturned:
            return 4
        case .appSwitchFailed:
            return 5
        case .invalidRequestURL:
            return 6
        case .fetchConfigurationFailed:
            return 7
        }
    }

    var errorDescription: String? {
        switch self {
        case .disabled:
            return "Venmo is not enabled for this merchant account."
        case .appNotAvailable:
            return "The Venmo app is not installed on this device, or it is not configured or available for app switch."
        case .bundleDisplayNameMissing:
            return "CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."
        case .invalidReturnURL(let missingValue):
            return "Return URL is missing \(missingValue)"
        case .invalidBodyReturned:
            return "The request returned a body that was missing or nil."
        case .appSwitchFailed:
            return "UIApplication failed to perform app switch to Venmo."
        case .invalidRequestURL(let description):
            return description
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        }
    }
}
