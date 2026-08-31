import Foundation

/// The lifecycle status of a Payment Action.
@objc public enum BTPaymentActionStatus: Int {
    
    /// The Payment Action has been created but does not yet have a payment method selected.
    case requiresPaymentMethod
    
    /// A payment method has been set and the Payment Action is ready to be confirmed.
    case readyForConfirmation
    
    /// The Payment Action has completed successfully. The underlying transaction has been submitted for settlement (or settled) and any selected payment details have been cleared.
    case succeeded
    
    /// The payment method has been authorized but funds have not yet been captured.
    case requiresCapture
    
    /// The Payment Action requires the customer to complete an additional action (e.g. 3D Secure challenge) before it can proceed.
    case requiresCustomerAction
    
    /// The Payment Action is being processed by the server and has not yet reached a terminal or actionable state.
    case processing
    
    /// The Payment Action was canceled and can no longer be used. The merchant server must create a new Payment Action to retry.
    case canceled
    
    /// The Payment Action expired before it could be completed. The client token can't be reused; the merchant server must create a new Payment Action.
    case expired
    
    /// The status returned by the server could not be mapped to a known case.
    case unknown
    
    var description: String {
        switch self {
        case .requiresPaymentMethod: return "REQUIRES_PAYMENT_METHOD"
        case .readyForConfirmation: return "READY_FOR_CONFIRMATION"
        case .succeeded: return "SUCCEEDED"
        case .requiresCapture: return "REQUIRES_CAPTURE"
        case .requiresCustomerAction: return "REQUIRES_CUSTOMER_ACTION"
        case .processing: return "PROCESSING"
        case .canceled: return "CANCELLED"
        case .expired: return "EXPIRED"
        case .unknown: return "UNKNOWN"
        }
    }
    
    static func status(from rawValue: String) -> BTPaymentActionStatus {
        switch rawValue {
        case BTPaymentActionStatus.requiresPaymentMethod.description:
            return .requiresPaymentMethod
        case BTPaymentActionStatus.readyForConfirmation.description:
            return .readyForConfirmation
        case BTPaymentActionStatus.succeeded.description:
            return .succeeded
        case BTPaymentActionStatus.requiresCapture.description:
            return .requiresCapture
        case BTPaymentActionStatus.requiresCustomerAction.description:
            return .requiresCustomerAction
        case BTPaymentActionStatus.processing.description:
            return .processing
        case BTPaymentActionStatus.canceled.description:
            return .canceled
        case BTPaymentActionStatus.expired.description:
            return .expired
        default:
            return .unknown
        }
    }
}
