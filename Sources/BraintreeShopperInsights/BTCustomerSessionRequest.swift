import Foundation

/// A `BTCustomerSessionRequest` that specifies options for the Payment Ready v2 flow.
public struct BTCustomerSessionRequest {
    
    /// The customer's details
    let customer: Customer
    /// The list of purchase units containing the amount and currency code.
    let purchaseUnits: [BTPurchaseUnit]?
}

public struct Customer {
    
    /// The customer's email address hashed via SHA256 algorithm.
    let hashedEmail: String?
    /// The customer's phone number hased via SHA256 algorithm.
    let hashedPhoneNumber: String?
    /// Checks whether the PayPal app is installed on the device.
    let paypalAppInstalled: Bool?
    /// Checks whether the Venmo app is installed on the device
    let venmoAppInstalled: Bool?
}

public struct BTPurchaseUnit {
    
    /// The amount that is charged for each purchase unit.
    let amount: Amount
}

public struct Amount {
    
    /// The value of the amount
    let value: String?
    /// The currency code for the amount
    let currencyCode: String?
}
