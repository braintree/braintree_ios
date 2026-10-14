import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable nesting
/// The POST body for the graphQL API `SetPaymentActionPaymentMethod`
struct SetPaymentActionPaymentMethodGraphQLBody: BTGraphQLEncodableBody {
    
    // swiftlint:disable indentation_width
    var query: String {
        """
        mutation SetPaymentActionPaymentMethod($input: SetPaymentActionPaymentMethodInput!) {
         setPaymentActionPaymentMethod(input: $input) {
          paymentAction {
        \(BTPaymentActionGraphQLFields.paymentActionSelectionSet)
          }
         }
        }
        """
    }
    
    let variables: Variables
    
    init(request: BTPaymentActionRequest) throws {
        self.variables = try Variables(request: request)
    }
    
    struct Variables: Encodable {
        
        let input: Input
        
        init(request: BTPaymentActionRequest) throws {
            self.input = try Input(request: request)
        }
        
        struct Input: Encodable {
            
            let paymentMethod: AnyEncodable
            
            init(request: BTPaymentActionRequest) throws {
                self.paymentMethod = AnyEncodable(try request.paymentMethodParameters())
            }
        }
    }
}
