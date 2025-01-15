// swiftlint:disable all
import Foundation

struct CreditCardPOSTBody: Encodable {
    var authenticationInsight: Bool?
    var merchantAccountId: String?
    var meta: Meta?
    let creditCard: CreditCard?
    
    private var usesGraphQL: Bool

    enum CodingKeys: String, CodingKey {
        case authenticationInsight
        case meta = "_meta"
        case merchantAccountId
        case creditCard = "credit_card"
    }

    init(
        card: BTCard,
        authenticationInsight: Bool? = nil,
        merchantAccountId: String?  = nil,
        meta: Meta? = nil,
        usesGraphQL: Bool = false
    ) {
        self.creditCard = CreditCard(card: card)
        self.authenticationInsight = authenticationInsight
        self.merchantAccountId = merchantAccountId
        self.meta = meta
        self.usesGraphQL = usesGraphQL
        
    }

    struct Meta: Encodable {
        var integration: String
        var source: String
        var sessionId: String

        init(integration: String, source: String, sessionId: String) {
            self.integration = integration
            self.source = source
            self.sessionId = sessionId
        }
    }

    /// POST Body Model
    struct CreditCard: Encodable {
        let billingAddress: BillingAddress?
        let number: String?
        let expirationMonth: String?
        let cvv: String?
        let options: Options?
        let expirationYear: String?
        let cardHolderName: String?

        init(
            card: BTCard
        ) {
            self.billingAddress = BillingAddress(card: card)
            self.number = card.number
            self.cvv = card.cvv
            self.options = Options(validate: card.shouldValidate)
            self.expirationMonth = card.expirationMonth
            self.expirationYear = card.expirationYear
            self.cardHolderName = card.cardholderName
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

        struct BillingAddress: Encodable {
            let firstName: String?
            let lastName: String?
            let company: String?
            let postalCode: String?
            let streetAddress: String?
            let extendedAddress: String?
            let locality: String?
            let region: String?
            let countryName: String?
            let countryCodeAlpha2: String?
            let countryCodeAlpha3: String?
            let countryCodeNumeric: String?
            
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

        struct Options: Encodable {
            let validate: Bool

            init(validate: Bool) {
                self.validate = validate
            }
        }
    }
}
