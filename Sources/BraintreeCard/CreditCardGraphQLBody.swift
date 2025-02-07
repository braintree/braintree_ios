// swiftlint:disable nesting

import Foundation

struct CreditCardGraphQLBody: Encodable {

    // MARK: - Internal Properties
    
    var variables: Variables
    var query: String
    var operationName: String
    
    init(card: BTCard) {
        self.variables = Variables(card: card)
        self.query = Self.cardTokenizationGraphQLMutation(authenticationInsightRequested: card.authenticationInsightRequested)
        self.operationName = "TokenizeCreditCard"
    }

    struct Variables: Encodable {

        var input: Input
        
        init(card: BTCard) {
            self.input = Input(card: card)
        }
        
        struct Input: Encodable {

            var creditCard: CreditCard
            var options: Options
            var authenticationInsightInput: AuthenticationInsightInput?

            init(card: BTCard) {
                self.creditCard = CreditCard(card: card)
                self.options = Options(validate: card.shouldValidate)
                
                if card.authenticationInsightRequested {
                    self.authenticationInsightInput = AuthenticationInsightInput(card: card)
                }
            }
            
            struct CreditCard: Encodable {

                var billingAddress: BillingAddress?
                var number: String?
                var expirationMonth: String?
                var cvv: String?
                var options: Options?
                var expirationYear: String?
                var cardholderName: String?

                init(card: BTCard) {
                    self.billingAddress = BillingAddress(card: card)
                    self.number = card.number
                    self.expirationMonth = card.expirationMonth
                    self.cvv = card.cvv
                    self.options = Options(validate: card.shouldValidate)
                    self.expirationYear = card.expirationYear
                    self.cardholderName = card.cardholderName
                }

                struct BillingAddress: Encodable {

                    var firstName: String?
                    var lastName: String?
                    var company: String?
                    var postalCode: String?
                    var streetAddress: String?
                    var extendedAddress: String?
                    var locality: String?
                    var region: String?
                    var countryName: String?
                    var countryCodeAlpha2: String?
                    var countryCodeAlpha3: String?
                    var countryCodeNumeric: String?

                    init(card: BTCard) {
                        self.firstName = card.firstName
                        self.lastName = card.lastName
                        self.company = card.company
                        self.postalCode = card.postalCode
                        self.streetAddress = card.streetAddress
                        self.extendedAddress = card.extendedAddress
                        self.locality = card.locality
                        self.region = card.region
                        self.countryName = card.countryName
                        self.countryCodeAlpha2 = card.countryCodeAlpha2
                        self.countryCodeAlpha3 = card.countryCodeAlpha3
                        self.countryCodeNumeric = card.countryCodeNumeric
                    }
                }

                struct Options: Encodable {

                    var validate: Bool?
                }
            }
            
            struct AuthenticationInsightInput: Encodable {
            
                var merchantAccountID: String?
                
                init(card: BTCard) {
                    self.merchantAccountID = card.merchantAccountID
                }

                enum CodingKeys: String, CodingKey {
                    case merchantAccountID = "merchantAccountId"
                }
            }

            struct Options: Encodable {

                var validate: Bool

                init(validate: Bool) {
                    self.validate = validate
                }
            }
        }
    }
    
    static func cardTokenizationGraphQLMutation(authenticationInsightRequested: Bool) -> String {
        var mutation = "mutation TokenizeCreditCard($input: TokenizeCreditCardInput!"

        if authenticationInsightRequested {
            mutation.append(", $authenticationInsightInput: AuthenticationInsightInput!")
        }

        // swiftlint:disable indentation_width
        mutation.append(
            """
            ) {
              tokenizeCreditCard(input: $input) {
                token
                creditCard {
                  brand
                  expirationMonth
                  expirationYear
                  cardholderName
                  last4
                  bin
                  binData {
                    prepaid
                    healthcare
                    debit
                    durbinRegulated
                    commercial
                    payroll
                    issuingBank
                    countryOfIssuance
                    productId
                  }
                }
            """
        )

        if authenticationInsightRequested {
            mutation.append(
                """
                    authenticationInsight(input: $authenticationInsightInput) {
                      customerAuthenticationRegulationEnvironment
                    }
                """
            )
        }

        mutation.append(
            """
              }
            }
            """
        )
        // swiftlint:enable indentation_width

        return mutation.replacingOccurrences(of: "\n", with: "")
    }
}
