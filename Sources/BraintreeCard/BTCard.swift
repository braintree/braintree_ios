import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The card tokenization request represents raw credit or debit card data provided by the customer.
/// Its main purpose is to serve as the input for tokenization.
@objcMembers public class BTCard: NSObject {

    // MARK: - Public Properties

    /// The card number
    public var number: String?

    /// The expiration month as a one or two-digit number on the Gregorian calendar
    public var expirationMonth: String?

    /// The expiration year as a two or four-digit number on the Gregorian calendar
    public var expirationYear: String?

    /// The card verification code (like CVV or CID).
    /// - Note: If you wish to create a CVV-only payment method nonce to verify a card already stored in your Vault,
    /// omit all other properties to only collect CVV.
    public var cvv: String?

    /// The postal code associated with the card's billing address
    public var postalCode: String?

    /// Optional: the cardholder's name.
    public var cardholderName: String?

    /// Optional: first name on the card.
    public var firstName: String?

    /// Optional: last name on the card.
    public var lastName: String?

    /// Optional: company name associated with the card.
    public var company: String?

    /// Optional: the street address associated with the card's billing address
    public var streetAddress: String?

    /// Optional: the extended address associated with the card's billing address
    public var extendedAddress: String?

    /// Optional: the city associated with the card's billing address
    public var locality: String?

    /// Optional: either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
    public var region: String?

    /// Optional: the country name associated with the card's billing address.
    /// - Note: Braintree only accepts specific country names.
    /// - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    public var countryName: String?

    /// Optional: the ISO 3166-1 alpha-2 country code specified in the card's billing address.
    /// - Note: Braintree only accepts specific alpha-2 values.
    /// - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    public var countryCodeAlpha2: String?

    /// Optional: the ISO 3166-1 alpha-3 country code specified in the card's billing address.
    /// - Note: Braintree only accepts specific alpha-3 values.
    /// - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    public var countryCodeAlpha3: String?

    ///  Optional: The ISO 3166-1 numeric country code specified in the card's billing address.
    ///  - Note: Braintree only accepts specific numeric values.
    /// - SeeAlso: https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
    public var countryCodeNumeric: String?

    /// Controls whether or not to return validations and/or verification results. By default, this is not enabled.
    /// - Note: Use this flag with caution. By enabling client-side validation, certain tokenize card requests may result in adding the card to the vault.
    /// These semantics are not currently documented.
    public var shouldValidate: Bool = false

    /// Optional: If authentication insight is requested. If this property is set to true, a `merchantAccountID` must be provided. Defaults to false.
    public var authenticationInsightRequested: Bool = false

    /// Optional: The merchant account ID.
    public var merchantAccountID: String?

    // MARK: - Internal Methods

    func parameters(apiClient: BTAPIClient) -> CreditCardPOSTBody {
        var creditCardBody = CreditCardPOSTBody(card: self)
        
        let meta = CreditCardPOSTBody.Meta(
            integration: apiClient.metadata.integration.stringValue,
            source: apiClient.metadata.source.stringValue,
            sessionId: apiClient.metadata.sessionID
        )
        
        creditCardBody.meta = meta
        
        if authenticationInsightRequested {
            creditCardBody.authenticationInsight = true
            creditCardBody.merchantAccountId = merchantAccountID
        }
        
        return creditCardBody
    }

    func graphQLParameters() -> CreditCardGraphQLBody {
        return CreditCardGraphQLBody(
            card: self,
            shouldValidate: shouldValidate,
            authenticationInsightRequested: authenticationInsightRequested,
            merchantAccountID: merchantAccountID
        )
    }
}
