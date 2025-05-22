import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `CreateCustomerSession`
struct CreateCustomerSessionMutationGraphQLBody: Encodable {
    
    var mutation: String
    var variables: Variables
    
    init(request: BTCustomerSessionRequest) throws {
        self.mutation = """
            mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                createCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
        self.variables = Variables(request: request)
    }
    
    struct Variables: Encodable {
        
        let input: InputParameters
        
        init(request: BTCustomerSessionRequest) {
            self.input = InputParameters(
                customer: Variables.InputParameters.Customer(
                    hashedEmail: request.customer.hashedEmail,
                    hashedPhoneNumber: request.customer.hashedPhoneNumber,
                    paypalAppInstalled: request.customer.paypalAppInstalled,
                    venmoAppInstalled: request.customer.venmoAppInstalled
                ),
                purchaseUnits: request.purchaseUnits?.map { purchaseUnit in
                    Variables.InputParameters.PurchaseUnit(
                        amount: Variables.InputParameters.PurchaseUnit.Amount(
                            value: purchaseUnit.amount.value,
                            currencyCode: purchaseUnit.amount.currencyCode
                        )
                    )
                }
            )
        }
        
        struct InputParameters: Encodable {
            
            var customer: Customer?
            var purchaseUnits: [PurchaseUnit]?
            
            struct Customer: Encodable {
                
                var hashedEmail: String?
                var hashedPhoneNumber: String?
                var paypalAppInstalled: Bool?
                var venmoAppInstalled: Bool?
            }
            
            struct PurchaseUnit: Encodable {
                
                var amount: Amount?
                
                struct Amount: Encodable {
                    
                    var value: String?
                    var currencyCode: String?
                }
            }
        }
    }
}
