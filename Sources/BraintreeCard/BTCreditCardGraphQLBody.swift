// swiftlint:disable all
import Foundation

class BTCreditCardGraphQLBody: NSObject, Encodable {

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

            var creditCard: CreditCard
            var options: Options
            var authenticationInsightInput: AuthenticationInsightInput?

            init(creditCard: CreditCard, options: Options, authenticationInsightInput: AuthenticationInsightInput? = nil) {
                self.creditCard = creditCard
                self.options = options
                self.authenticationInsightInput = authenticationInsightInput
            }
            
            class CreditCard: Encodable {
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

                class BillingAddress: Encodable {
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

                class Options: Encodable {
                    var validate: Bool?

                    init(validate: Bool? = nil) {
                        self.validate = validate
                    }
                }
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
