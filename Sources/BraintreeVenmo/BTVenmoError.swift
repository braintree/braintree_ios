import Foundation

/// Error codes associated with Venmo App Switch
public enum BTVenmoAppSwitchError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. The error returned from the Venmo return URL
    case returnURLError(Int, String?)

    public static var errorDomain: String {
        "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .returnURLError(let errorCode, _):
            return errorCode
        }
    }

    public var errorDescription: String? {
        switch self {
        case .returnURLError(_, let errorMessage):
            return errorMessage
        }
    }
}

/// Error codes associated with Venmo
public enum BTVenmoError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. Venmo is not enabled
    case disabled

    /// 2. Bundle display name is nil
    case bundleDisplayNameMissing

    /// 3. App Switch could not complete
    case appSwitchFailed

    /// 4. Return URL is invalid
    case invalidReturnURL(String)

    /// 5. No body was returned from the request
    case invalidBodyReturned

    /// 6. Invalid request URL
    case invalidRedirectURL(String)

    /// 7. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// 8. Enriched Customer Data is disabled
    case enrichedCustomerDataDisabled
    
    /// 9.  The Venmo flow was canceled by the user
    case canceled

    /// 10. One or more values in redirect URL are invalid
    case invalidRedirectURLParameter

    public static var errorDomain: String {
        "com.braintreepayments.BTVenmoErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .disabled:
            return 1
        case .bundleDisplayNameMissing:
            return 2
        case .appSwitchFailed:
            return 3
        case .invalidReturnURL:
            return 4
        case .invalidBodyReturned:
            return 5
        case .invalidRedirectURL:
            return 6
        case .fetchConfigurationFailed:
            return 7
        case .enrichedCustomerDataDisabled:
            return 8
        case .canceled:
            return 9
        case .invalidRedirectURLParameter:
            return 10
        }
    }

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
        case .disabled:
            return "Venmo is not enabled for this merchant account."
        case .bundleDisplayNameMissing:
            return "CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."
        case .appSwitchFailed:
            return "UIApplication failed to perform app switch to Venmo."
        case .invalidReturnURL(let missingValue):
            return "Return URL is missing \(missingValue)"
        case .invalidBodyReturned:
            return "The request returned a body that was missing or nil."
        case .invalidRedirectURL(let description):
            return description
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .enrichedCustomerDataDisabled:
            return "Cannot collect customer data when ECD is disabled. Enable this feature in the Control Panel to collect this data."
        case .canceled:
            return "Venmo flow was canceled by the user."
        case .invalidRedirectURLParameter:
            return "One or more values in redirect URL are invalid."
        }
    }
}
