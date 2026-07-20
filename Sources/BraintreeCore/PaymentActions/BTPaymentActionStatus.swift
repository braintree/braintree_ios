import Foundation

/// The lifecycle status of a Payment Action. 
public enum BTPaymentActionStatus {
    case requiresPaymentMethod
    case readyForConfirmation
    case succeeded
    case requiresCapture
    case canceled
    case expired
    case requiresCustomerAction
    case processing
    case unknown
    
    public init(rawValue: String) {
        switch rawValue {
        case "REQUIRES_PAYMENT_METHOD": self = .requiresPaymentMethod
        case "READY_FOR_CONFIRMATION": self = .readyForConfirmation
        case "SUCCEEDED": self = .succeeded
        case "REQUIRES_CAPTURE": self = .requiresCapture
        case "CANCELED": self = .canceled
        case "EXPIRED": self = .expired
        case "REQUIRES_CUSTOMER_ACTION": self = .requiresCustomerAction
        case "PROCESSING": self = .processing
        default: self = .unknown
        }
    }
}
