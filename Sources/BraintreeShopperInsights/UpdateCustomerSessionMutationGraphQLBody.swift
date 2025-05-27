import Foundation

// swiftlint:disable nesting
/// The POST body for the GraphQL mutation `CreateCustomerSession`
struct UpdateCustomerSessionMutationGraphQLBody: Encodable {
    
    var mutation: String
    var variables: Variables
    
    init(request: BTCustomerSessionRequest) throws {
        self.mutation = """
            mutation UpdateCustomerSession($input: UpdateCustomerSessionInput!) {
                updateCustomerSession(input: $input) {
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
                
//                func encode(to encoder: any Encoder) throws {
//                    var container = encoder.container(keyedBy: CodingKeys.self)
//                    
//                    try container.encodeIfPresent(hashedEmail, forKey: .hashedEmail)
//                    try container.encodeIfPresent(hashedPhoneNumber, forKey: .hashedPhoneNumber)
//                    try container.encodeIfPresent(paypalAppInstalled, forKey: .paypalAppInstalled)
//                    try container.encodeIfPresent(venmoAppInstalled, forKey: .venmoAppInstalled)
//                }
//                
//                enum CodingKeys: String, CodingKey {
//                    case hashedEmail
//                    case hashedPhoneNumber
//                    case paypalAppInstalled
//                    case venmoAppInstalled
//                }
            }
            
            struct PurchaseUnit: Encodable {
                
                var amount: Amount?
                
                struct Amount: Encodable {
                    
                    var value: String?
                    var currencyCode: String?
                    
//                    func encode(to encoder: any Encoder) throws {
//                        var container = encoder.container(keyedBy: CodingKeys.self)
//                        
//                        try container.encodeIfPresent(value, forKey: .value)
//                        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
//                    }
//                    
//                    enum CodingKeys: String, CodingKey {
//                        case value
//                        case currencyCode
//                    }
                }
            }
        }
    }
}
