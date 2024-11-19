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
        var authenticationInsightInput: AuthenticationInsightInput?

        init(input: Input, authenticationInsightInput: AuthenticationInsightInput? = nil) {
            self.input = input
        }
        
        class AuthenticationInsightInput: Encodable {
        
            var merchantAccountId: String?
            
            init(merchantAccountId: String) {
                self.merchantAccountId = merchantAccountId
            }
        }

        class Input: Encodable {
            var creditCard: BTCreditCardBody.CreditCard
            var options: BTCreditCardBody.CreditCard.Options

            init(creditCard: BTCreditCardBody.CreditCard, options: BTCreditCardBody.CreditCard.Options) {
                self.creditCard = creditCard
                self.options = options
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
