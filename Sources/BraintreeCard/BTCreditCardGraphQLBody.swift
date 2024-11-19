import Foundation

class BTCreditCardGraphQLBody: Encodable {
    var variables: Variables
    var query: String
    var operationName: String

    init(variables: Variables, query: String, operationName: String) {
        self.variables = variables
        self.query = query
        self.operationName = operationName
    }

    class Variables: Encodable {
        var input: Input

        init(input: Input) {
            self.input = input
        }
        
        class Input: Encodable {
            var creditCard: BTCreditCardBody.CreditCard
            var options: BTCreditCardBody.CreditCard.Options
            var authenticationInsightInput: AuthenticationInsightInput?

            init(creditCard: BTCreditCardBody.CreditCard, options: BTCreditCardBody.CreditCard.Options, authenticationInsightInput: AuthenticationInsightInput? = nil) {
                self.creditCard = creditCard
                self.options = options
                self.authenticationInsightInput = authenticationInsightInput
            }
            
            class AuthenticationInsightInput: Encodable {
            
                var merchantAccountId: String?
                
                init(merchantAccountId: String) {
                    self.merchantAccountId = merchantAccountId
                }
            }

            class Options: Encodable {
                var validate: Bool

                init(validate: Bool) {
                    self.validate = validate
                }
            }
        }
    }
}
