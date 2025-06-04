import Foundation

/// A `BTCustomerSessionRequest`for creating a customer session.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTCustomerSessionRequest {
    
    let hashedEmail: String?
    let hashedPhoneNumber: String?
    let paypalAppInstalled: Bool?
    let venmoAppInstalled: Bool?
    let purchaseUnits: [BTPurchaseUnit]?
    
    /// Creates a BTCustomerSessionRequest
    /// - Parameters:
    ///   - hashedEmail: Optional: The customer's email address hashed via SHA256 algorithm.
    ///   - hashedPhoneNumber: Optional: The customer's phone number hased via SHA256 algorithm.
    ///   - paypalAppInstalled: Optional: Checks whether the PayPal app is installed on the device.
    ///   - venmoAppInstalled: Optional: Checks whether the Venmo app is installed on the device
    ///   - purchaseUnits: Optional: The list of purchase units containing the amount and currency code.
    /// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
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
