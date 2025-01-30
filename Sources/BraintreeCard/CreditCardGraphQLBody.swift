// swiftlint:disable all
import Foundation

struct CreditCardGraphQLBody: Encodable {

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
                self.authenticationInsightInput = AuthenticationInsightInput(card: card)
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
                    
                    if card.firstName != nil {
                        self.billingAddress = BillingAddress(card: card)
                    }
                    
                    
                    self.number = card.number
                    self.expirationMonth = card.expirationMonth
                    self.cvv = card.cvv
                    self.expirationYear = card.expirationYear
                    self.cardholderName = card.cardholderName
                }
                
                func encode(to encoder: any Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    if let billingAddress {
                        try container.encodeIfPresent(billingAddress, forKey: .billingAddress)
                    }
                    
                    try container.encodeIfPresent(number, forKey: .number)
                    try container.encodeIfPresent(expirationMonth, forKey: .expirationMonth)
                    try container.encodeIfPresent(cvv, forKey: .cvv)
                    try container.encodeIfPresent(options, forKey: .options)
                    try container.encodeIfPresent(expirationYear, forKey: .expirationYear)
                    try container.encodeIfPresent(cardholderName, forKey: .cardholderName)
                }
                
                enum CodingKeys: String, CodingKey {
                    case billingAddress
                    case number
                    case expirationMonth
                    case cvv
                    case options
                    case expirationYear
                    case cardholderName
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

                    init(
                        card: BTCard
                    ) {
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

                    init(validate: Bool? = nil) {
                        self.validate = validate
                    }
                }
            }
            
            struct AuthenticationInsightInput: Encodable {
            
                var merchantAccountId: String?
                
                init(card: BTCard) {
                    
                    guard card.authenticationInsightRequested else {
                        self.merchantAccountId = nil
                        return
                    }
                    
                    self.merchantAccountId = card.merchantAccountID
                }
                
                init(merchantAccountId: String) {
                    self.merchantAccountId = merchantAccountId
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
