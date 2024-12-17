import Foundation

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

    func parameters() -> BTCreditCardBody.CreditCard {
        let cardBody = creditCardParams()
        
        cardBody.billingAddress = billingAddress()
        cardBody.options = BTCreditCardBody.CreditCard.Options(validate: shouldValidate)
        
        return cardBody
    }

    private func creditCardParams() -> BTCreditCardBody.CreditCard {
        BTCreditCardBody.CreditCard(
            number: number,
            expirationMonth: expirationMonth,
            cvv: cvv,
            expirationYear: expirationYear,
            cardHolderName: cardholderName
        )
    }

    private func billingAddress() -> BTCreditCardBody.CreditCard.BillingAddress {
        BTCreditCardBody.CreditCard.BillingAddress(
            firstName: firstName,
            lastName: lastName,
            company: company,
            postalCode: postalCode,
            streetAddress: streetAddress,
            extendedAddress: extendedAddress,
            locality: locality,
            region: region,
            countryName: countryName,
            countryCodeAlpha2: countryCodeAlpha2,
            countryCodeAlpha3: countryCodeAlpha3,
            countryCodeNumeric: countryCodeNumeric
        )
    }

    func graphQLParameters() -> BTCreditCardGraphQLBody {
        let cardBody = BTCreditCardGraphQLBody.Variables.Input.CreditCard(
            number: number,
            expirationMonth: expirationMonth,
            cvv: cvv,
            expirationYear: expirationYear,
            cardHolderName: cardholderName
        )
        
        if firstName == nil {
            cardBody.billingAddress = BTCreditCardGraphQLBody.Variables.Input.CreditCard.BillingAddress(
                firstName: firstName,
                lastName: lastName,
                company: company,
                postalCode: postalCode,
                streetAddress: streetAddress,
                extendedAddress: extendedAddress,
                locality: locality,
                region: region,
                countryName: countryName,
                countryCodeAlpha2: countryCodeAlpha2,
                countryCodeAlpha3: countryCodeAlpha3,
                countryCodeNumeric: countryCodeNumeric
            )
        }

        
        let options = BTCreditCardGraphQLBody.Variables.Input.Options(validate: shouldValidate)
        
        let input = BTCreditCardGraphQLBody.Variables.Input(
            creditCard: cardBody,
            options: options
        )
        
        let variables = BTCreditCardGraphQLBody.Variables(input: input)
        
        if authenticationInsightRequested {
            if let merchantAccountID {
                let merchantAccountID = BTCreditCardGraphQLBody.Variables.Input.AuthenticationInsightInput(merchantAccountId: merchantAccountID)
                
                input.authenticationInsightInput = merchantAccountID
            }
        }
        
        let body = BTCreditCardGraphQLBody(variables: variables, query: cardTokenizationGraphQLMutation(), operationName: "TokenizeCreditCard")

        inspectEncodable(body)
        return body
    }
    
    func inspectEncodable<T: Encodable>(_ object: T) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // Optional formatting
            let jsonData = try encoder.encode(object)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded Object:\n\(jsonString)")
            }
        } catch {
            print("Failed to encode object: \(error)")
        }
    }

    // MARK: - Private Methods

    private func buildCardDictionary(isGraphQL: Bool) -> [String: Any] {
        var cardDictionary: [String: Any] = [:]

        if let number {
            cardDictionary["number"] = number
        }

        if let expirationMonth {
            cardDictionary[isGraphQL ? "expirationMonth" : "expiration_month"] = expirationMonth
        }

        if let expirationYear {
            cardDictionary[isGraphQL ? "expirationYear" : "expiration_year"] = expirationYear
        }

        if let cvv {
            cardDictionary["cvv"] = cvv
        }

        if let cardholderName {
            cardDictionary[isGraphQL ? "cardholderName" : "cardholder_name"] = cardholderName
        }

        return cardDictionary
    }

    // swiftlint:disable cyclomatic_complexity
    private func buildBillingAddressDictionary(isGraphQL: Bool) -> [String: String] {
        var billingAddressDictionary: [String: String] = [:]

        if let firstName {
            billingAddressDictionary[isGraphQL ? "firstName" : "first_name"] = firstName
        }

        if let lastName {
            billingAddressDictionary[isGraphQL ? "lastName" : "last_name"] = lastName
        }

        if let company {
            billingAddressDictionary["company"] = company
        }

        if let postalCode {
            billingAddressDictionary[isGraphQL ? "postalCode" : "postal_code"] = postalCode
        }

        if let streetAddress {
            billingAddressDictionary[isGraphQL ? "streetAddress" : "street_address"] = streetAddress
        }

        if let extendedAddress {
            billingAddressDictionary[isGraphQL ? "extendedAddress" : "extended_address"] = extendedAddress
        }

        if let locality {
            billingAddressDictionary["locality"] = locality
        }

        if let region {
            billingAddressDictionary["region"] = region
        }

        if let countryName {
            billingAddressDictionary[isGraphQL ? "countryName" : "country_name"] = countryName
        }

        if let countryCodeAlpha2 {
            billingAddressDictionary[isGraphQL ? "countryCodeAlpha2" : "country_code_alpha2"] = countryCodeAlpha2
        }

        if let countryCodeAlpha3 {
            billingAddressDictionary[isGraphQL ? "countryCode" : "country_code_alpha3"] = countryCodeAlpha3
        }

        if let countryCodeNumeric {
            billingAddressDictionary[isGraphQL ? "countryCodeNumeric" : "country_code_numeric"] = countryCodeNumeric
        }

        return billingAddressDictionary
    }
    // swiftlint:enable cyclomatic_complexity

    private func cardTokenizationGraphQLMutation() -> String {
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
