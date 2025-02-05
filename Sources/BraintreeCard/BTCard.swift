import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The card tokenization request represents raw credit or debit card data provided by the customer.
/// Its main purpose is to serve as the input for tokenization.
@objcMembers public class BTCard: NSObject {

    // MARK: - Internal Properties

    let number: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String
    let postalCode: String?
    let cardholderName: String?
    let firstName: String?
    let lastName: String?
    let company: String?
    let streetAddress: String?
    let extendedAddress: String?
    let locality: String?
    let region: String?
    let countryName: String?
    let countryCodeAlpha2: String?
    let countryCodeAlpha3: String?
    let countryCodeNumeric: String?
    let shouldValidate: Bool
    let authenticationInsightRequested: Bool
    let merchantAccountID: String?

    // MARK: - Initializer
    
    /// Creates a Card
    /// - Parameters:
    ///   - number: The card number.
    ///   - expirationMonth: The expiration month as a one or two-digit number on the Gregorian calendar.
    ///   - expirationYear:The expiration year as a two or four-digit number on the Gregorian calendar.
    ///   - cvv: The card verification code (like CVV or CID).
    ///   - postalCode: Optional: The postal code associated with the card's billing address.
    ///   - cardholderName: Optional: the cardholder's name.
    ///   - firstName: Optional: first name on the card.
    ///   - lastName: Optional: last name on the card.
    ///   - company: Optional: company name associated with the card.
    ///   - streetAddress: Optional: the street address associated with the card's billing address.
    ///   - extendedAddress: Optional: the extended address associated with the card's billing address.
    ///   - locality: Optional: the city associated with the card's billing address.
    ///   - region: Optional: either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    ///   - countryName: Optional: the country name associated with the card's billing address.
    ///     - Note: Braintree only accepts specific country names.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    ///   - countryCodeAlpha2: Optional: the ISO 3166-1 alpha-2 country code specified in the card's billing address.
    ///     - Note: Braintree only accepts specific alpha-2 values.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    ///   - countryCodeAlpha3: Optional: the ISO 3166-1 alpha-3 country code specified in the card's billing address.
    ///     - Note: Braintree only accepts specific alpha-3 values.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    ///   - countryCodeNumeric: Optional: The ISO 3166-1 numeric country code specified in the card's billing address.
    ///     - Note: Braintree only accepts specific numeric values.
    ///     - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    ///   - shouldValidate: Controls whether or not to return validations and/or verification results. By default, this is not enabled.
    ///     - Note: Use this flag with caution. By enabling client-side validation, certain tokenize card requests may result in adding the card to the vault. These semantics are not currently documented.
    ///   - authenticationInsightRequested: Optional: If authentication insight is requested. If this property is set to `true`, a `merchantAccountID` must be provided. Defaults to `false`.
    ///   - merchantAccountID: Optional: The merchant account ID.
    public init(
        number: String,
        expirationMonth: String,
        expirationYear: String,
        cvv: String,
        postalCode: String? = nil,
        cardholderName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        streetAddress: String? = nil,
        extendedAddress: String? = nil,
        locality: String? = nil,
        region: String? = nil,
        countryName: String? = nil,
        countryCodeAlpha2: String? = nil,
        countryCodeAlpha3: String? = nil,
        countryCodeNumeric: String? = nil,
        shouldValidate: Bool = false,
        authenticationInsightRequested: Bool = false,
        merchantAccountID: String? = nil
    ) {
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cvv = cvv
        self.postalCode = postalCode
        self.cardholderName = cardholderName
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.streetAddress = streetAddress
        self.extendedAddress = extendedAddress
        self.locality = locality
        self.region = region
        self.countryName = countryName
        self.countryCodeAlpha2 = countryCodeAlpha2
        self.countryCodeAlpha3 = countryCodeAlpha3
        self.countryCodeNumeric = countryCodeNumeric
        self.shouldValidate = shouldValidate
        self.authenticationInsightRequested = authenticationInsightRequested
        self.merchantAccountID = merchantAccountID
    }
    
    /// Creates a new instance of `BTCard` with only a CVV value,
    /// setting default values for all other parameters.
    /// This initializer should only be used if you wish to create a
    /// CVV-only payment method nonce to verify a card already stored in your Vault.
    /// - Parameters:
    ///   - cvv: The card verification code (like CVV or CID).
    public convenience init(cvv: String) {
        self.init(number: "", expirationMonth: "", expirationYear: "", cvv: cvv)
    }
    
    // MARK: - Internal Methods

    func graphQLParameters(apiClient: BTAPIClient) -> CreditCardPOSTBody {
        CreditCardPOSTBody(
            card: self,
            metadata: apiClient.metadata
        )
    }
            
    func parameters() -> CreditCardGraphQLBody {
        CreditCardGraphQLBody(card: self)
    }
}
