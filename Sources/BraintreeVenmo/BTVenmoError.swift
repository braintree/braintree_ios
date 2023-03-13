import Foundation

/// Error codes associated with Venmo
enum BTVenmoError: Error, CustomNSError, LocalizedError {

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
