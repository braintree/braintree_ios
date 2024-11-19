import Foundation

class BTCreditCardBody: Encodable {
    var authenticationInsight: Bool?
    var merchantAccountId: String?
    var meta: Meta?
    var creditCard: CreditCard?
    
    private var usesGraphQL: Bool

    enum CodingKeys: String, CodingKey {
        case authenticationInsight
        case meta = "_meta"
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
        
        private var usesGraphQL: Bool

        init(
            billingAddress: BillingAddress? = nil,
            number: String?,
            expirationMonth: String?,
            cvv: String?,
            options: Options? = nil,
            expirationYear: String?,
            cardHolderName: String?,
            usesGraphQL: Bool)
        {
            self.billingAddress = billingAddress
            self.number = number
            self.cvv = cvv
            self.options = options
            self.expirationMonth = expirationMonth
            self.expirationYear = expirationYear
            self.cardHolderName = cardHolderName
            
            self.usesGraphQL = usesGraphQL
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCodingKeys.self)
            
            let billingAddressKey = "billing_address"
            let numberKey = "number"
            let cvvKey = "cvv"
            let optionsKey = "options"
            let expirationMonthKey = usesGraphQL ? "expirationMonth" : "expiration_month"
            let expirationYearKey = usesGraphQL ? "expirationYear" : "expiration_year"
            let cardHolderNameKey = usesGraphQL ? "cardholderName" : "cardholder_name"

            try container.encode(billingAddress, forKey: DynamicCodingKeys(stringValue: billingAddressKey)!)
            
            try container.encode(options, forKey: DynamicCodingKeys(stringValue: optionsKey)!)
            
            if let number {
                try container.encode(number, forKey: DynamicCodingKeys(stringValue: numberKey)!)
            }
            
            if let cvv {
                try container.encode(cvv, forKey: DynamicCodingKeys(stringValue: cvvKey)!)
            }
            
            if let expirationMonth {
                try container.encode(expirationMonth, forKey: DynamicCodingKeys(stringValue: expirationMonthKey)!)
            }
            
            if let expirationYear {
                try container.encode(expirationYear, forKey: DynamicCodingKeys(stringValue: expirationYearKey)!)
            }
            
            if let cardHolderName {
                try container.encode(cardHolderName, forKey: DynamicCodingKeys(stringValue: cardHolderNameKey)!)
            }
        }

        private struct DynamicCodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue: Int) {
                self.intValue = intValue
                self.stringValue = "\(intValue)"
            }
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
            
            private var usesGraphQL: Bool

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
                countryCodeNumeric: String?,
                usesGraphQL: Bool = false
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

                self.usesGraphQL = usesGraphQL
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: DynamicCodingKeys.self)
                
                // Dynamically set keys based on usesGraphQL
                let firstNameKey = usesGraphQL ? "firstName" : "first_name"
                let lastNameKey = usesGraphQL ? "lastName" : "last_name"
                let companyKey = usesGraphQL ? "company" : "company"
                let postalCodeKey = usesGraphQL ? "postalCode" : "postal_code"
                let streetAddressKey = usesGraphQL ? "streetAddress" : "street_address"
                let extendedAddressKey = usesGraphQL ? "extendedAddress" : "extended_address"
                let localityKey = usesGraphQL ? "locality" : "locality"
                let regionKey = usesGraphQL ? "region" : "region"
                let countryNameKey = usesGraphQL ? "countryName" : "country_name"
                let countryCodeAlpha2Key = usesGraphQL ? "countryCodeAlpha2" : "country_code_alpha2"
                let countryCodeAlpha3Key = usesGraphQL ? "countryCodeAlpha3" : "country_code_alpha3"
                let countryCodeNumericKey = usesGraphQL ? "countryCodeNumeric" : "country_code_numeric"

                // Encode each property conditionally if it is not nil
                if let firstName = firstName {
                    try container.encode(firstName, forKey: DynamicCodingKeys(stringValue: firstNameKey)!)
                }
                if let lastName = lastName {
                    try container.encode(lastName, forKey: DynamicCodingKeys(stringValue: lastNameKey)!)
                }
                if let company = company {
                    try container.encode(company, forKey: DynamicCodingKeys(stringValue: companyKey)!)
                }
                if let postalCode = postalCode {
                    try container.encode(postalCode, forKey: DynamicCodingKeys(stringValue: postalCodeKey)!)
                }
                if let streetAddress = streetAddress {
                    try container.encode(streetAddress, forKey: DynamicCodingKeys(stringValue: streetAddressKey)!)
                }
                if let extendedAddress = extendedAddress {
                    try container.encode(extendedAddress, forKey: DynamicCodingKeys(stringValue: extendedAddressKey)!)
                }
                if let locality = locality {
                    try container.encode(locality, forKey: DynamicCodingKeys(stringValue: localityKey)!)
                }
                if let region = region {
                    try container.encode(region, forKey: DynamicCodingKeys(stringValue: regionKey)!)
                }
                if let countryName = countryName {
                    try container.encode(countryName, forKey: DynamicCodingKeys(stringValue: countryNameKey)!)
                }
                if let countryCodeAlpha2 = countryCodeAlpha2 {
                    try container.encode(countryCodeAlpha2, forKey: DynamicCodingKeys(stringValue: countryCodeAlpha2Key)!)
                }
                if let countryCodeAlpha3 = countryCodeAlpha3 {
                    try container.encode(countryCodeAlpha3, forKey: DynamicCodingKeys(stringValue: countryCodeAlpha3Key)!)
                }
                if let countryCodeNumeric = countryCodeNumeric {
                    try container.encode(countryCodeNumeric, forKey: DynamicCodingKeys(stringValue: countryCodeNumericKey)!)
                }
            }

            private struct DynamicCodingKeys: CodingKey {
                var stringValue: String
                var intValue: Int?

                init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                init?(intValue: Int) {
                    self.intValue = intValue
                    self.stringValue = "\(intValue)"
                }
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
