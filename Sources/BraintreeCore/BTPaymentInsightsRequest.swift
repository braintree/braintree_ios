import Foundation

/// Buyer data required to use the Payment Insights feature.
/// - Note: This feature is in beta. It's public API may change in future releases.
@objcMembers public class BTPaymentInsightsRequest: NSObject {
    
    /// The buyer's email address.
    public let email: String
    
    /// The buyer's country code prefix to the national telephone number. An identifier for a specific country.
    public let phoneCountryCode: String
    
    /// The buyer's national phone number.
    public let phoneNationalNumber: String
    
    /// Initialize a `BTPaymentInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    ///   - phoneCountryCode: The buyer's country code prefix to the national telephone number. An identifier for a specific country.
    ///   - phoneNationalNumber: The buyer's national phone number.
    init(email: String, phoneCountryCode: String, phoneNationalNumber: String) {
        self.email = email
        self.phoneCountryCode = phoneCountryCode
        self.phoneNationalNumber = phoneNationalNumber
    }
}
