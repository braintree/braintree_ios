import Foundation

///  Error details associated with Payment Actions.
public enum BTPaymentActionError: Error, CustomNSError, LocalizedError, Equatable {
    
    /// 0. Response is missing a Payment Action id
    case missingID
    
    /// 1. Response is missing a Payment Action status
    case missingStatus
    
    /// 2. Failed to decode the Payment Action response
    case decodingFailure
    
    public static var errorDomain: String {
        "com.braintreepayments.BTPaymentActionErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .missingID: return 0
        case .missingStatus: return 1
        case .decodingFailure: return 2
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .missingID:
            return [NSLocalizedDescriptionKey: "Payment Action response is missing an id."]
        case .missingStatus:
            return [NSLocalizedDescriptionKey: "Payment Action response is missing a status."]
        case .decodingFailure:
            return [NSLocalizedDescriptionKey: "Failed to decode Payment Action response."]
        }
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: BTPaymentActionError, rhs: BTPaymentActionError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
