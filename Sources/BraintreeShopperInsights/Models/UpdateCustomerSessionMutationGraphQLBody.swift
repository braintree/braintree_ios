import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `UpdateCustomerSession`
struct UpdateCustomerSessionMutationGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest, sessionID: String) throws {
        query = """
            mutation UpdateCustomerSession($input: UpdateCustomerSessionInput!) {
                updateCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
        variables = Variables(request: request, sessionID: sessionID)
    }
    
    struct Variables: Encodable {
        
        let input: InputParameters
        
        init(request: BTCustomerSessionRequest, sessionID: String) {
            input = InputParameters(request: request, sessionID: sessionID)
        }
        
        struct InputParameters: Encodable {
            
            let sessionID: String
            let customer: Customer?
            let purchaseUnits: [PurchaseUnit]?
            
            init(request: BTCustomerSessionRequest, sessionID: String) {
                self.sessionID = sessionID
                customer = Customer(request: request)
                purchaseUnits = request.purchaseUnits?.compactMap {
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
                let paypalAppInstalled: Bool?
                let venmoAppInstalled: Bool?
                
                init(request: BTCustomerSessionRequest) {
                    hashedEmail = request.hashedEmail
                    hashedPhoneNumber = request.hashedPhoneNumber
                    paypalAppInstalled = request.paypalAppInstalled
                    venmoAppInstalled = request.venmoAppInstalled
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
}
