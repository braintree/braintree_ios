/// The account type
@objc public enum BTThreeDSecureAccountType: Int {
    
    /// Unspecified
    case unspecified
    
    /// Credit
    case credit
    
    /// Debit
    case debit

    var stringValue: String? {
        switch self {
        case .credit:
            return "credit"
        case .debit:
            return "debit"
        case .unspecified:
            return nil
        }
    }
}
