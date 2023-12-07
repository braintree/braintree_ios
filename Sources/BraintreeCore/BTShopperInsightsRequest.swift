import Foundation

/// Buyer data required to use the Shopper Insights feature.
/// - Note: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTShopperInsightsRequest {
    
    // MARK: - Private Properties
    
    /// The buyer's email address.
    private var email: String?
    
    /// The buyer's phone number details.
    private var phone: Phone?
    
    // MARK: - Initializers

    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    ///   - phone: The buyer's phone number details.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    public init(email: String, phone: Phone) {
        self.email = email
        self.phone = phone
    }
    
    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    public init(email: String) {
        self.email = email
    }
    
    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - phone: The buyer's phone number details.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    public init(phone: Phone) {
        self.phone = phone
    }
    
    // MARK: - Data Types
    
    /// Buyer's phone number details for use fetching Shopper Insights.
    public struct Phone {
        
        /// The buyer's country code prefix to the national telephone number. An identifier for a specific country.
        /// Must not contain special characters.
        private let phoneCountryCode: String
        
        /// The buyer's national phone number. Must not contain special characters.
        private let phoneNationalNumber: String
    }
}
