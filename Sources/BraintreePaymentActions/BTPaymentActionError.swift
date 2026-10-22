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

    /// 4. `handleNextAction` was called while a previous invocation on this client was still in flight
    case handleNextActionAlreadyInProgress

    /// 5. A Payment Action's `version` decreased between two fetches within a single `handleNextAction`
    /// drive loop, which should never happen and indicates a stale or out-of-order response.
    case versionAnomaly

    /// 6. Deallocated BTPaymentActionsClient
    case deallocated

    public static var errorDomain: String {
        "com.braintreepayments.BTPaymentActionErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .missingID:
            return 0
        case .missingStatus:
            return 1
        case .decodingFailure:
            return 2
        case .missingParameters:
            return 3
        case .handleNextActionAlreadyInProgress:
            return 4
        case .versionAnomaly:
            return 5
        case .deallocated:
            return 6
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
        case .handleNextActionAlreadyInProgress:
            return "handleNextAction was called while a previous invocation on this client was still in flight."
        case .versionAnomaly:
            return "Payment Action version decreased between fetches during handleNextAction."
        case .deallocated:
            return "BTPaymentActionsClient has been deallocated."
        }
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: BTPaymentActionError, rhs: BTPaymentActionError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
