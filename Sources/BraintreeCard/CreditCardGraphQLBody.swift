// swiftlint:disable all
import Foundation

struct CreditCardGraphQLBody: Encodable {

    var variables: Variables
    var query: String
    var operationName: String
    
    init(card: BTCard,
         shouldValidate: Bool,
         authenticationInsightRequested: Bool,
         merchantAccountID: String?
    ) {
        let cardBody = CreditCardGraphQLBody.Variables.Input.CreditCard(
            number: card.number,
            expirationMonth: card.expirationMonth,
            cvv: card.cvv,
            expirationYear: card.expirationYear,
            cardHolderName: card.cardholderName
        )
        
        let options = Self.Variables.Input.Options(validate: shouldValidate)

        var input = CreditCardGraphQLBody.Variables.Input(
            creditCard: cardBody,
            options: options
        )

        let variables = CreditCardGraphQLBody.Variables(input: input)
        
        if authenticationInsightRequested {
            if let merchantAccountID {
                let merchantAccountID = CreditCardGraphQLBody
                    .Variables
                    .Input
                    .AuthenticationInsightInput(
                        merchantAccountId: merchantAccountID
                    )

                input.authenticationInsightInput = merchantAccountID
            } else {
                let merchantAccountID = CreditCardGraphQLBody
                    .Variables
                    .Input
                    .AuthenticationInsightInput()

                input.authenticationInsightInput = merchantAccountID
            }
        }

        self.variables = variables
       
        if card.firstName != nil {
            self.variables.input.creditCard.billingAddress = Self.Variables.Input.CreditCard.BillingAddress(
                firstName: card.firstName,
                lastName: card.lastName,
                company: card.company,
                postalCode: card.postalCode,
                streetAddress: card.streetAddress,
                extendedAddress: card.extendedAddress,
                locality: card.locality,
                region: card.region,
                countryName: card.countryName,
                countryCodeAlpha2: card.countryCodeAlpha2,
                countryCodeAlpha3: card.countryCodeAlpha3,
                countryCodeNumeric: card.countryCodeNumeric
            )
        }
        
        self.query = Self.cardTokenizationGraphQLMutation(authenticationInsightRequested: authenticationInsightRequested)
        self.operationName = "TokenizeCreditCard"
    }

    struct Variables: Encodable {

        var input: Input

        init(input: Input) {
            self.input = input
        }
        
        struct Input: Encodable {

            var creditCard: CreditCard
            var options: Options
            var authenticationInsightInput: AuthenticationInsightInput?

            init(creditCard: CreditCard, options: Options, authenticationInsightInput: AuthenticationInsightInput? = nil) {
                self.creditCard = creditCard
                self.options = options
                self.authenticationInsightInput = authenticationInsightInput
            }
            
            struct CreditCard: Encodable {
                var billingAddress: BillingAddress?
                var number: String?
                var expirationMonth: String?
                var cvv: String?
                var options: Options?
                var expirationYear: String?
                var cardholderName: String?

                init(
                    billingAddress: BillingAddress? = nil,
                    number: String? = nil,
                    expirationMonth: String? = nil,
                    cvv: String? = nil,
                    options: Options? = nil,
                    expirationYear: String? = nil,
                    cardHolderName: String? = nil
                ) {
                    self.billingAddress = billingAddress
                    self.number = number
                    self.expirationMonth = expirationMonth
                    self.cvv = cvv
                    self.options = options
                    self.expirationYear = expirationYear
                    self.cardholderName = cardHolderName
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
                        firstName: String?,
                        lastName: String?,
                        company: String?,
                        postalCode: String?,
                        streetAddress: String?,
                        extendedAddress: String?,
                        locality: String?,
                        region: String?,
                        countryName: String?,
                        countryCodeAlpha2: String?,
                        countryCodeAlpha3: String?,
                        countryCodeNumeric: String?
                    ) {
                        self.firstName = firstName
                        self.lastName = lastName
                        self.company = company
                        self.postalCode = postalCode
                        self.streetAddress = streetAddress
                        self.extendedAddress = extendedAddress
                        self.locality = locality
                        self.region = region
                        self.countryName = countryName
                        self.countryCodeAlpha2 = countryCodeAlpha2
                        self.countryCodeAlpha3 = countryCodeAlpha3
                        self.countryCodeNumeric = countryCodeNumeric
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
                
                init() {
                    self.merchantAccountId = nil
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
