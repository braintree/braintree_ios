import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct CardSetPaymentMethodGraphQLBody: BTGraphQLEncodableBody {
    
    var variables: Variables
    var query: String
    var operationName: String
    
    init(card: BTCard) {
        self.variables = Variables(card: card)
        self.query = Self.setPaymentMethodGraphQLMutation()
        self.operationName = "SetPaymentMethodPaymentAction"
    }
    
    struct Variables: Encodable {
        var input: Input
        
        init(card: BTCard) {
            self.input = Input(card: card)
        }
        
        struct Input: Encodable {
            var number: String?
            var expirationMonth: String?
            var expirationYear: String?
            var cvv: String?
            var billingAddress: BillingAddress?
            
            init(card: BTCard) {
                self.number = card.number
                self.expirationMonth = card.expirationMonth
                self.expirationYear = card.expirationYear
                self.cvv = card.cvv
                self.billingAddress = BillingAddress(card)
            }
            
            struct BillingAddress: Encodable {
                var postalCode: String?
                var streetAddress: String?
                var extendedAddress: String?
                var locality: String?
                var region: String?
                var countryName: String?
                
                init?(_ card: BTCard) {
                    let billingAddressProperties = [
                        card.postalCode,
                        card.streetAddress,
                        card.extendedAddress,
                        card.locality,
                        card.region,
                        card.countryName
                    ]

                    if billingAddressProperties.allSatisfy({ $0?.isEmpty ?? true }) {
                        return nil
                    }

                    self.postalCode = card.postalCode
                    self.streetAddress = card.streetAddress
                    self.extendedAddress = card.extendedAddress
                    self.locality = card.locality
                    self.region = card.region
                    self.countryName = card.countryName
                }
            }
        }
    }
    
    static func setPaymentMethodGraphQLMutation() -> String {
        """
        mutation SetPaymentMethodPaymentAction($input: SetPaymentMethodInput!) {
          setPaymentMethodPaymentAction(input: $input) {
            paymentAction {
              id
              status
              nextAction {
                type
                songbirdUrl
                cardinalAuthenticationJwt
                bin
                acsUrl
                challengePayload
              }
              selectedPaymentMethod {
                paymentMethodId
                usage
              }
            }
          }
        }
        """.replacingOccurrences(of: "\n", with: "")
    }
}

