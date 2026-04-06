#if canImport(BraintreeCard)
import BraintreeCard
#endif

extension BTCard {

    /// Creates a `BTCard` with only optional metadata fields for use with `BTCardFields`.
    /// Card number, expiration month, expiration year, and CVV are managed internally
    /// by the `BTCardFields` form and should not be set by the merchant.
    public convenience init(
        cardholderName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        postalCode: String? = nil,
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
        self.init(
            number: "",
            expirationMonth: "",
            expirationYear: "",
            cvv: "",
            postalCode: postalCode,
            cardholderName: cardholderName,
            firstName: firstName,
            lastName: lastName,
            company: company,
            streetAddress: streetAddress,
            extendedAddress: extendedAddress,
            locality: locality,
            region: region,
            countryName: countryName,
            countryCodeAlpha2: countryCodeAlpha2,
            countryCodeAlpha3: countryCodeAlpha3,
            countryCodeNumeric: countryCodeNumeric,
            shouldValidate: shouldValidate,
            authenticationInsightRequested: authenticationInsightRequested,
            merchantAccountID: merchantAccountID
        )
    }
}
