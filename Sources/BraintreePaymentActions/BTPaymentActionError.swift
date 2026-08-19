import Foundation

///  Error details associated with Payment Actions.
public enum BTPaymentActionError: Error, CustomNSError, LocalizedError, Equatable {
    
    /// 0. Response is missing a Payment Action id
    case missingID
    
    /// 1. Response is missing a Payment Action status
    case missingStatus
    
    /// 2. Failed to decode the Payment Action response
    case decodingFailure
    
    /// 3. The `BTPaymentActionRequest` subclass did not override `paymentMethodParameters()`
    case missingParameters
    
    public static var errorDomain: String {
        "com.braintreepayments.BTPaymentActionErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .missingID: return 0
        case .missingStatus: return 1
        case .decodingFailure: return 2
        case .missingParameters: return 3
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .missingID:
            return "Payment Action response is missing an id."
        case .missingStatus:
            return "Payment Action response is missing a status."
        case .decodingFailure:
            return "Failed to decode Payment Action response."
        case .missingParameters:
            return "BTPaymentActionRequest subclass did not override paymentMethodParameters()."
        }
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: BTPaymentActionError, rhs: BTPaymentActionError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
