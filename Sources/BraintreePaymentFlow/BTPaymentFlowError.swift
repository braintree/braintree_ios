import Foundation

/// Error codes associated with Payment Flow
enum BTPaymentFlowError: Error, CustomNSError, LocalizedError {
    
    /// Unknown error
    case unknown

    /// PaymentFlow is disabled in configuration
    case disabled
    
    /// UIApplication failed to switch to browser
    case appSwitchFailed
    
    /// Braintree SDK is integrated incorrectly
    case integration
    
    /// No payment flow account data returned
    case noAccountData
    
    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow
    case canceled(String)

    /// Missing nonce value in account response
    case failedToCreateNonce
    
    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed
    
    /// No URL found to display for payment authorization
    case missingRedirectURL
    
    /// No URL was returned via the ASWebAuthenticationSession completion callback
    case missingReturnURL

    /// ASWebAuthentication error
    case webSessionError(Error)

    static var errorDomain = "com.braintreepayments.BTPaymentFlowErrorDomain"

    var errorCode: Int {
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

    var errorDescription: String {
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
        case .canceled(let paymentFlowName):
            return "\(paymentFlowName) flow was canceled by the user."
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
}
