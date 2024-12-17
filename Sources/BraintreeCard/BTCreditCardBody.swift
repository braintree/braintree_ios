// swiftlint:disable all
import Foundation

class BTCreditCardBody: NSObject, Encodable {
    var authenticationInsight: Bool?
    var merchantAccountId: String?
    var meta: Meta?
    var creditCard: CreditCard?
    
    private var usesGraphQL: Bool

    enum CodingKeys: String, CodingKey {
        case authenticationInsight
        case meta = "_meta"
        case merchantAccountId
        case creditCard = "credit_card"
    }

    init(
        authenticationInsight: Bool? = nil,
        merchantAccountId: String?  = nil,
        meta: Meta? = nil,
        creditCard: CreditCard? = nil,
        usesGraphQL: Bool = false
    ) {
        self.authenticationInsight = authenticationInsight
        self.merchantAccountId = merchantAccountId
        self.meta = meta
        self.creditCard = creditCard
        self.usesGraphQL = usesGraphQL
        
    }

    class Meta: Encodable {
        var integration: String
        var source: String
        var sessionId: String

        init(integration: String, source: String, sessionId: String) {
            self.integration = integration
            self.source = source
            self.sessionId = sessionId
        }
    }

    class CreditCard: Encodable {
        var billingAddress: BillingAddress?
        var number: String?
        var expirationMonth: String?
        var cvv: String?
        var options: Options?
        var expirationYear: String?
        var cardHolderName: String?

        init(
            billingAddress: BillingAddress? = nil,
            number: String?,
            expirationMonth: String?,
            cvv: String?,
            options: Options? = nil,
            expirationYear: String?,
            cardHolderName: String?
        ) {
            self.billingAddress = billingAddress
            self.number = number
            self.cvv = cvv
            self.options = options
            self.expirationMonth = expirationMonth
            self.expirationYear = expirationYear
            self.cardHolderName = cardHolderName
        }
        
        enum CodingKeys: String, CodingKey {
            case billingAddress = "billing_address"
            case number
            case expirationMonth = "expiration_month"
            case cvv
            case options
            case expirationYear = "expiration_year"
            case cardHolderName = "cardholder_name"
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
            
            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case company
                case postalCode = "postal_code"
                case streetAddress = "street_address"
                case extendedAddress = "extended_address"
                case locality
                case region
                case countryName = "country_name"
                case countryCodeAlpha2 = "country_code_alpha2"
                case countryCodeAlpha3 = "country_code_alpha3"
                case countryCodeNumeric = "country_code_numeric"
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
