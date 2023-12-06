import Foundation

/// Buyer data required to use the Shopper Insights feature.
/// - Note: This feature is in beta. It's public API may change or be removed in future releases.
@objcMembers public class BTShopperInsightsRequest: NSObject {
    
    /// The buyer's email address.
    private let email: String
    
    /// The buyer's country code prefix to the national telephone number. An identifier for a specific country.
    /// Must not contain special characters.
    private let phoneCountryCode: String
    
    /// The buyer's national phone number. Must not contain special characters.
    private let phoneNationalNumber: String
    
    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    ///   - phoneCountryCode: The buyer's country code prefix to the national telephone number. An identifier for a specific country. Must not contain special characters.
    ///   - phoneNationalNumber: The buyer's national phone number. Must not contain special characters.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    public init(email: String, phoneCountryCode: String, phoneNationalNumber: String) {
        self.email = email
        self.phoneCountryCode = phoneCountryCode
        self.phoneNationalNumber = phoneNationalNumber
    }
}
