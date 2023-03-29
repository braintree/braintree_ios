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
}
