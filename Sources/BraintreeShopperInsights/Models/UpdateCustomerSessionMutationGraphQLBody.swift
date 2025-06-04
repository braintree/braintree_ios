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
            self.input = InputParameters(request: request)
        }
        
        struct InputParameters: Encodable {
            
            let customer: Customer?
            let purchaseUnits: [PurchaseUnit]?
            
            init(request: BTCustomerSessionRequest) {
                self.customer = Customer(request: request)
                self.purchaseUnits = request.purchaseUnits?.compactMap { PurchaseUnit(purchaseUnit: $0) }
            }
            
            struct Customer: Encodable {
                
                let hashedEmail: String?
                let hashedPhoneNumber: String?
                let paypalAppInstalled: Bool?
                let venmoAppInstalled: Bool?
                
                init(request: BTCustomerSessionRequest) {
                    self.hashedEmail = request.hashedEmail
                    self.hashedPhoneNumber = request.hashedPhoneNumber
                    self.paypalAppInstalled = request.paypalAppInstalled
                    self.venmoAppInstalled = request.venmoAppInstalled
                }
            }
            
            struct PurchaseUnit: Encodable {
                
                let amount: Amount?
                
                init(purchaseUnit: BTPurchaseUnit) {
                    self.amount = Amount(
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
