/// The shipping method
@objc public enum BTThreeDSecureShippingMethod: Int {
    
    /// Unspecified
    case unspecified
    
    /// Same Day
    case sameDay
    
    /// Expedited
    case expedited
    
    /// Priority
    case priority
    
    /// Ground
    case ground
    
    /// Electronic Delivery
    case electronicDelivery
    
    /// Ship to Store
    case shipToStore

    var stringValue: String? {
        switch self {
        case .sameDay:
            return "01"
        case .expedited:
            return "02"
        case .priority:
            return "03"
        case .ground:
            return "04"
        case .electronicDelivery:
            return "05"
        case .shipToStore:
            return "06"
        case .unspecified:
            return nil
        }
    }
}
