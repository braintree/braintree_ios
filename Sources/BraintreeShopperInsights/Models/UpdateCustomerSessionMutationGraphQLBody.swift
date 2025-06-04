import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `UpdateCustomerSession`
struct UpdateCustomerSessionMutationGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest) {
        query = """
            mutation UpdateCustomerSession($input: UpdateCustomerSessionInput!) {
                updateCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
        variables = Variables(request: request)
    }
    
    struct Variables: Encodable {
        
        let input: InputParameters
        
        init(request: BTCustomerSessionRequest) {
            input = InputParameters(request: request)
        }
        
        struct InputParameters: Encodable {
            
            let customer: Customer?
            let purchaseUnits: [PurchaseUnit]?
            
            init(request: BTCustomerSessionRequest) {
                customer = Customer(request: request)
                purchaseUnits = request.purchaseUnits?.compactMap {
                    PurchaseUnit(purchaseUnit: $0)
                }
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
