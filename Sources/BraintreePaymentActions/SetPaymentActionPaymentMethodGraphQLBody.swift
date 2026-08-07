import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct SetPaymentActionPaymentMethodGraphQLBody: BTGraphQLEncodableBody {
    
    let query = """
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
    
    init(request: any BTPaymentActionRequest) {
        self.variables = Variables(request: request)
    }
    
    struct Variables: Encodable {
        
        let input: Input
        
        init(request: any BTPaymentActionRequest) {
            self.input = Input(request: request)
        }
        
        struct Input: Encodable {
            let paymentActionId: String
            let paymentMethod: AnyEncodable
            
            init(request: any BTPaymentActionRequest) {
                self.paymentActionId = request.paymentActionID
                self.paymentMethod = AnyEncodable(request.paymentMethodParameters())
            }
        }
    }
}
