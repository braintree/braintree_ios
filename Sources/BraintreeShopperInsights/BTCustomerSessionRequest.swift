import Foundation

// swiftlint:disable nesting
/// A `BTCustomerSessionRequest` that specifies options for the Payment Ready v2 flow.
struct BTCustomerSessionRequest: Encodable {
    
    let customer: Customer
    let purchaseUnits: [BTPurchaseUnit]?
    
    struct Customer: Encodable {
        
        let hashedEmail: String?
        let hashedPhoneNumber: String?
        let paypalAppInstalled: Bool?
        let venmoAppInstalled: Bool?
    }
    
    struct BTPurchaseUnit: Encodable {
        
        let amount: Amount
        
        struct Amount: Encodable {
            
            let value: String?
            let currencyCode: String?
        }
    }
}
