import Foundation

/// The lifecycle status of a Payment Action. 
@objc public enum BTPaymentActionStatus: Int {
    case requiresPaymentMethod
    case readyForConfirmation
    case succeeded
    case requiresCapture
    case canceled
    case expired
    case requiresCustomerAction
    case processing
    case unknown
    
    static func status(from rawValue: String) -> BTPaymentActionStatus {
        switch rawValue {
        case "REQUIRES_PAYMENT_METHOD": return .requiresPaymentMethod
        case "READY_FOR_CONFIRMATION": return .readyForConfirmation
        case "SUCCEEDED": return .succeeded
        case "REQUIRES_CAPTURE": return .requiresCapture
        case "CANCELED": return .canceled
        case "EXPIRED": return .expired
        case "REQUIRES_CUSTOMER_ACTION": return .requiresCustomerAction
        case "PROCESSING": return .processing
        default: return .unknown
        }
    }
}
