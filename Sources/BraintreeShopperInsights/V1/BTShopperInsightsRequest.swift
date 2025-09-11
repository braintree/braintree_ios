import Foundation

/// Buyer data required to use the Shopper Insights feature.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTShopperInsightsRequest {
    
    // MARK: - Internal Properties
    
    var email: String?
    var phone: Phone?
    
    // MARK: - Initializers

    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    ///   - phone: The buyer's phone number details.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
    public init(email: String, phone: Phone) {
        self.email = email
        self.phone = phone
    }
    
    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - email: The buyer's email address.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
    public init(email: String) {
        self.email = email
    }
    
    /// Initialize a `BTShopperInsightsRequest`
    /// - Parameters:
    ///   - phone: The buyer's phone number details.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
    public init(phone: Phone) {
        self.phone = phone
    }
}

/// Buyer's phone number details for use with the Shopper Insights feature.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct Phone: Encodable {
    
    private let countryCode: String
    private let nationalNumber: String
    
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case nationalNumber = "national_number"
    }
    
    /// Initialize a `BTShopperInsightsRequest.Phone`.
    /// - Parameters:
    ///   - countryCode: The buyer's country code prefix to the national telephone number. An identifier for a specific country. Must not contain special characters.
    ///   - nationalNumber: The buyer's national phone number. Must not contain special characters.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
    public init(countryCode: String, nationalNumber: String) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
    }
}
