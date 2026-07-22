import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable nesting
/// The POST body for the graphQL `setPaymentActionPaymentMethod` mutation.
struct CardSetPaymentMethodGraphQLBody: BTGraphQLEncodableBody {
    
    var variables: Variables
    var query: String
    var operationName: String
    
    init(card: BTCard) {
        self.variables = Variables(card: card)
        self.query = Self.setPaymentActionPaymentMethodMutation()
        self.operationName = "SetPaymentActionPaymentMethod"
    }
    
    struct Variables: Encodable {
        
        var input: Input
        
        init(card: BTCard) {
            self.input = Input(card: card)
        }
        
        struct Input: Encodable {
            
            var paymentMethod: PaymentMethod
            
            init(card: BTCard) {
                self.paymentMethod = PaymentMethod(card: card)
            }
            
            struct PaymentMethod: Encodable {
                
                var paymentMethodDetails: PaymentMethodDetails
                
                init(card: BTCard) {
                    self.paymentMethodDetails = PaymentMethodDetails(card: card)
                }
                
                struct PaymentMethodDetails: Encodable {
                    
                    var card: Card
                    
                    init(card: BTCard) {
                        self.card = Card(card: card)
                    }
                    
                    struct Card: Encodable {
                        
                        var number: String?
                        var expirationMonth: String?
                        var expirationYear: String?
                        var cvv: String?
                        var cardholderName: String?
                        var billingAddress: BillingAddress?
                        
                        typealias BillingAddress = CreditCardGraphQLBody.Variables.Input.CreditCard.BillingAddress
                        
                        init(card: BTCard) {
                            self.number = card.number
                            self.expirationMonth = card.expirationMonth
                            self.expirationYear = card.expirationYear
                            self.cvv = card.cvv
                            self.cardholderName = card.cardholderName
                            self.billingAddress = BillingAddress(card: card)
                        }
                    }
                }
            }
        }
    }
    
    static func setPaymentActionPaymentMethodMutation() -> String {
        // swiftlint:disable indentation_width
        """
        mutation SetPaymentActionPaymentMethod($input: SetPaymentActionPaymentMethodInput!) {
          setPaymentActionPaymentMethod(input: $input) {
            paymentAction {
              id
              status
            }
          }
        }
        """.replacingOccurrences(of: "\n", with: "")
    }
}
