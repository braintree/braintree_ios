import Foundation

/// The POST body for the `createCustomerSession` GraphQL API.
struct BTCustomerSessionRequest: Encodable {
    
    let customer: BTCustomer
    let purchaseUnits: [BTPurchaseUnit]?
    
    struct BTCustomer: Encodable {
        
        let hashedEmail: String?
        let hashedPhoneNumber: String?
        let paypalAppInstalled: Bool?
        let venmoAppInstalled: Bool?
    }
    
    struct BTPurchaseUnit: Encodable {
        
        let amount: String
        let currencyCode: String
    }
}
