import Foundation

/// Error codes associated with Payment Flow
public enum BTLocalPaymentError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. Local Payments are disabled in configuration
    case disabled
    
    /// 2. UIApplication failed to switch to browser
    case appSwitchFailed
    
    /// 3. Braintree SDK is integrated incorrectly
    case integration
    
    /// 4. No payment flow account data returned
    case noAccountData
    
    /// 5. Payment flow was canceled, typically initiated by the user when exiting early from the flow
    case canceled(String)

    /// 6. Missing nonce value in account response
    case failedToCreateNonce
    
    /// 7. Failed to fetch Braintree configuration
    case fetchConfigurationFailed
    
    /// 8. No URL found to display for payment authorization
    case missingRedirectURL
    
    /// 9. No URL was returned via the ASWebAuthenticationSession completion callback
    case missingReturnURL

    /// 10. ASWebAuthentication error
    case webSessionError(Error)

    public static var errorDomain = "com.braintreepayments.BTLocalPaymentErrorDomain"

    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .disabled:
            return 1
        case .appSwitchFailed:
            return 2
        case .integration:
            return 3
        case .noAccountData:
            return 4
        case .canceled:
            return 5
        case .failedToCreateNonce:
            return 6
        case .fetchConfigurationFailed:
            return 7
        case .missingRedirectURL:
            return 8
        case .missingReturnURL:
            return 9
        case .webSessionError:
            return 10
        }
    }

    public var errorDescription: String {
        switch self {
        case .unknown:
            return ""
        case .disabled:
            return "Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments."
        case .appSwitchFailed:
            return "Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists."
        case .integration:
            return "Failed to begin payment flow: BTLocalPaymentRequest localPaymentFlowDelegate can not be nil."
        case .noAccountData:
            return "Missing response data from /v1/payment_methods/ call."
        case .canceled(let localPaymentName):
            return "\(localPaymentName) flow was canceled by the user."
        case .failedToCreateNonce:
            return "Received valid response data, but missing `nonce` key value."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .missingRedirectURL:
            return "Failed to complete payment flow due to missing redirectURL."
        case .missingReturnURL:
            return "An error occured completing the payment authorization flow. The ASWebAuthenticationSession returned a nil URL."
        case .webSessionError(let error):
            return "ASWebAuthenticationSession failed with \(error.localizedDescription)"
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTLocalPaymentError, rhs: BTLocalPaymentError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
