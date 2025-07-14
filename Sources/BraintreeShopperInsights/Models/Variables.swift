import Foundation

// swiftlint:disable nesting
struct Variables: Encodable {
    
    let input: InputParameters
    
    init(request: BTCustomerSessionRequest?, sessionID: String? = nil) {
        input = InputParameters(request: request, sessionID: sessionID)
    }
    
    struct InputParameters: Encodable {
        
        let sessionID: String?
        let customer: Customer?
        let purchaseUnits: [PurchaseUnit]?
        
        init(request: BTCustomerSessionRequest?, sessionID: String?) {
            self.sessionID = sessionID
            customer = Customer(request: request)
            purchaseUnits = request?.purchaseUnits?.compactMap {
                PurchaseUnit(purchaseUnit: $0)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case sessionID = "sessionId"
            case customer
            case purchaseUnits
        }
        
        struct Customer: Encodable {
            
            let hashedEmail: String?
            let hashedPhoneNumber: String?
            let payPalAppInstalled: Bool?
            let venmoAppInstalled: Bool?
            
            init(request: BTCustomerSessionRequest?) {
                hashedEmail = request?.hashedEmail
                hashedPhoneNumber = request?.hashedPhoneNumber
                payPalAppInstalled = request?.payPalAppInstalled
                venmoAppInstalled = request?.venmoAppInstalled
            }
            
            enum CodingKeys: String, CodingKey {
                case hashedEmail
                case hashedPhoneNumber
                case payPalAppInstalled = "paypalAppInstalled"
                case venmoAppInstalled
            }
        }
        
        struct PurchaseUnit: Encodable {
            
            let amount: Amount?
            
            init(purchaseUnit: BTPurchaseUnit) {
                amount = Amount(
                    value: purchaseUnit.amount,
                    currencyCode: purchaseUnit.currencyCode
                )
            }
            
            struct Amount: Encodable {
                
                let value: String?
                let currencyCode: String?
            }
        }
    }
}
