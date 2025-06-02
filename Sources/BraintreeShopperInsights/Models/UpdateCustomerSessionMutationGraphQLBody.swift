import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `CreateCustomerSession`
struct UpdateCustomerSessionMutationGraphQLBody: Encodable {
    
    let mutation: String
    let variables: Variables
    
    init(request: BTCustomerSessionRequest) {
        mutation = """
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
                self.customer = Customer(customer: request.customer)
                self.purchaseUnits = request.purchaseUnits?.map { PurchaseUnit(purchaseUnit: $0) }
            }
            
            struct Customer: Encodable {
                
                let hashedEmail: String?
                let hashedPhoneNumber: String?
                let paypalAppInstalled: Bool?
                let venmoAppInstalled: Bool?
                
                init(customer: BTCustomerSessionRequest.BTCustomer) {
                    self.hashedEmail = customer.hashedEmail
                    self.hashedPhoneNumber = customer.hashedPhoneNumber
                    self.paypalAppInstalled = customer.paypalAppInstalled
                    self.venmoAppInstalled = customer.venmoAppInstalled
                }
            }
            
            struct PurchaseUnit: Encodable {
                
                let amount: Amount?
                
                init(purchaseUnit: BTCustomerSessionRequest.BTPurchaseUnit) {
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
