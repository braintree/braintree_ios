import Foundation

/// Amounts of the items purchased.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTPurchaseUnit {
    
    let amount: String
    let currencyCode: String
    
    /// Creates a BTPurchaseUnit
    /// - Parameters:
    ///   - amount: The amount of money, either a whole number or a number with up to 3 decimal places.
    ///   - currencyCode: The currency code for the monetary amount.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
    public init(amount: String, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }
}
