import Foundation

// swiftlint:disable nesting
/// The POST body for the `createCustomerSession` GraphQL API.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
struct BTCustomerSessionRequest: Encodable {
    
    let customer: Customer
    let purchaseUnits: [BTPurchaseUnit]?
    
    enum CodingKeys: String, CodingKey {
        case customer
        case purchaseUnits
    }
    
    struct Customer: Encodable {
        
        let hashedEmail: String?
        let hashedPhoneNumber: String?
        let paypalAppInstalled: Bool?
        let venmoAppInstalled: Bool?
        
        enum CodingKeys: String, CodingKey {
            case hashedEmail
            case hashedPhoneNumber
            case paypalAppInstalled
            case venmoAppInstalled
        }
    }
    
    struct BTPurchaseUnit: Encodable {
        
        let amount: String
        let currencyCode: String
        
        enum CodingKeys: String, CodingKey {
            case amount
            case currencyCode
        }
    }
}
