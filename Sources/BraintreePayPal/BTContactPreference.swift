/// Contact information section preference within the payment flow
@objc public enum BTContactPreference: Int {
    /// Default
    case none

    /// Disables the contact information section in the payment flow
    case noContactInformation

    /// Enables the contact information section but disables the buyer's ability to update the contact information
    case retainContactInformation

    /// Enables the contact information section and enables the buyer's ability to update the contact information    
    case updateContactInformation
}

extension BTContactPreference {

    var stringValue: String {
        switch self {
        case .noContactInformation:
            return "NO_CONTACT_INFO"
        case .retainContactInformation:
            return "RETAIN_CONTACT_INFO"
        case .updateContactInformation:
            return "UPDATE_CONTACT_INFO"
        case .none:
            return ""
        }
    }
}
