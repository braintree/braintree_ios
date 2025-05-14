import Foundation

/// The POST body for the `createCustomerSession` GraphQL API.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
struct BTCustomerSessionRequest {
    
    let hashedEmail: String?
    let hashedPhoneNumber: String?
    let paypalAppInstalled: Bool?
    let venmoAppInstalled: Bool?
    let purchaseUnits: [BTPurchaseUnit]?
    
    struct BTPurchaseUnit {
        
        let amount: String
        let currencyCode: String
    }
}
