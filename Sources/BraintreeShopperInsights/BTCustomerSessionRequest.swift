import Foundation

/// A `BTCustomerSessionRequest`for creating a customer session.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTCustomerSessionRequest {
    
    /// The customer's email address hashed via SHA256 algorithm.
    let hashedEmail: String?
    
    /// The customer's phone number hased via SHA256 algorithm.
    let hashedPhoneNumber: String?
    
    /// Checks whether the PayPal app is installed on the device.
    let paypalAppInstalled: Bool?
    
    /// Checks whether the Venmo app is installed on the device
    let venmoAppInstalled: Bool?
    
    /// The list of purchase units containing the amount and currency code.
    let purchaseUnits: [BTPurchaseUnit]?
    
    public init(
        hashedEmail: String? = nil,
        hashedPhoneNumber: String? = nil,
        paypalAppInstalled: Bool? = nil,
        venmoAppInstalled: Bool? = nil,
        purchaseUnits: [BTPurchaseUnit]? = nil
    ) {
        self.hashedEmail = hashedEmail
        self.hashedPhoneNumber = hashedPhoneNumber
        self.paypalAppInstalled = paypalAppInstalled
        self.venmoAppInstalled = venmoAppInstalled
        self.purchaseUnits = purchaseUnits
    }
}

/// Amounts of the items purchased.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTPurchaseUnit {
    
    /// The amount of money, either a whole number or a number with up to 3 decimal places.
    let amount: String
    
    /// The currency code for the monetary amount.
    let currencyCode: String
    
    public init(amount: String, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }
}
