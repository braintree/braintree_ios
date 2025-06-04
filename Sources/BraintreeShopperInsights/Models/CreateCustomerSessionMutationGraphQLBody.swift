import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `CreateCustomerSession`
struct CreateCustomerSessionMutationGraphQLBody: Encodable {
    
    let query: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest) throws {
        query = """
            mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                createCustomerSession(input: $input) {
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
                    PurchaseUnit(request: $0)
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
                
                init(request: BTPurchaseUnit) {
                    amount = Amount(
                        value: request.amount,
                        currencyCode: request.currencyCode
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
