/// Contact information section preference within the payment flow
public enum BTContactPreference: String {
    
    /// Disables the contact information section in the payment flow
    /// - Maps to: "NO_CONTACT_INFO"
    case noContactInformation = "NO_CONTACT_INFO"

    /// Enables the contact information section but disables the buyer's ability to update the contact information
    /// - Maps to: "RETAIN_CONTACT_INFO"
    case retainContactInformation = "RETAIN_CONTACT_INFO"

    /// Enables the contact information section and enables the buyer's ability to update the contact information
    /// - Maps to: "UPDATE_CONTACT_INFO"
    case updateContactInformation = "UPDATE_CONTACT_INFO"
}
