import Foundation

/// Buyer data required to use the Shopper Insights feature.
/// - Note: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTShopperInsightsRequest {
    
    // MARK: - Private Properties
    
    private var email: String?
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
}

/// Buyer's phone number details for use with the Shopper Insights feature.
/// - Note: This feature is in beta. It's public API may change or be removed in future releases.
public struct Phone {
    
    private let countryCode: String
    private let nationalNumber: String
    
    /// Initialize a `BTShopperInsightsRequest.Phone`.
    /// - Parameters:
    ///   - phoneCountryCode: The buyer's country code prefix to the national telephone number. An identifier for a specific country. Must not contain special characters.
    ///   - phoneNationalNumber: The buyer's national phone number. Must not contain special characters. Must not contain special characters.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    init(countryCode: String, nationalNumber: String) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
    }
}
