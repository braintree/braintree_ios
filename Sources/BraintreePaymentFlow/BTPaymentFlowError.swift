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
    
    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow
    case canceled(String)
    
    /// No payment flow account data returned
    case noAccountData

    /// Missing nonce value in account response
    case failedToCreateNonce
    
    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed

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
        case .canceled:
            return 4
        case .noAccountData:
            return 5
        case .failedToCreateNonce:
            return 6
        case .fetchConfigurationFailed:
            return 7
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
        case .canceled(let paymentFlowName):
            return "\(paymentFlowName) flow was canceled by the user."
        case .noAccountData:
            return "Missing response data from /v1/payment_methods/ call."
        case .failedToCreateNonce:
            return "Received valid response data, but missing `nonce` key value."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        }
    }
}
