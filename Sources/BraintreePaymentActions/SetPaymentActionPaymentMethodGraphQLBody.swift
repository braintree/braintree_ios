import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable nesting
/// The POST body for the graphQL API `SetPaymentActionPaymentMethod`
struct SetPaymentActionPaymentMethodGraphQLBody: BTGraphQLEncodableBody {
    
    // swiftlint:disable indentation_width
    let query =
    """
    mutation SetPaymentActionPaymentMethod($input: SetPaymentActionPaymentMethodInput!) {
     setPaymentActionPaymentMethod(input: $input) {
      paymentAction {
      id
      status
      }
     }
    }
    """
    
    let variables: Variables
    
    init(request: BTPaymentActionRequest) {
        self.variables = Variables(request: request)
    }
    
    struct Variables: Encodable {
        
        let input: Input
        
        init(request: BTPaymentActionRequest) {
            self.input = Input(request: request)
        }
        
        struct Input: Encodable {
            
            let paymentActionId: String
            let paymentMethod: AnyEncodable
            
            init(request: BTPaymentActionRequest) {
                self.paymentActionId = request.paymentActionID
                self.paymentMethod = AnyEncodable(request.paymentMethodParameters())
            }
        }
    }
}
