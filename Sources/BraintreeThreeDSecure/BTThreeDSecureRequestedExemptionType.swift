/// 3D Secure requested exemption type
@objc public enum BTThreeDSecureRequestedExemptionType: Int {
    
    /// Unspecified
    case unspecified
    
    /// Low value
    case lowValue
    
    /// Secure corporate
    case secureCorporate
    
    /// Trusted beneficiary
    case trustedBeneficiary
    
    /// Transaction risk analysis
    case transactionRiskAnalysis

    var stringValue: String? {
        switch self {
        case .lowValue:
            return "low_value"
        case .secureCorporate:
            return "secure_corporate"
        case .trustedBeneficiary:
            return "trusted_beneficiary"
        case .transactionRiskAnalysis:
            return "transaction_risk_analysis"
        case .unspecified:
            return nil
        }
    }
}
