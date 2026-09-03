import Foundation

/// The card details to submit as the payment method for a Payment Action.
@objcMembers public class BTCreditCard: BTPaymentActionRequest {
    
    // MARK: - Internal Properties
    
    let cardNumber: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String?
    let cardholderName: String?
    let streetAddress: String?
    let extendedAddress: String?
    let locality: String?
    let region: String?
    let postalCode: String?
    let countryCodeAlpha2: String?
    
    // MARK: - Initializer
    
    /// Initialize a `BTCardPaymentActionRequest`
    /// - Parameters:
    ///   - cardNumber: Required: The card number.
    ///   - expirationMonth: Required: The 2-digit expiration month i.e. "08"
    ///   - expirationYear: Required: The 2 or 4-digit expiration year.
    ///   - cvv: Optional: The card verification value. Optional depending on merchant configuration.
    ///   - cardholderName: Optional: The cardholder's name as it appears on the card.
    ///   - streetAddress: Optional: The street address line of the cardholder's billing address.
    ///   - extendedAddress: Optional: The extended address line (e.g. apartment, suite, or unit number) of the cardholder's billing address.
    ///   - locality: Optional: The city or locality of the cardholder's billing address.
    ///   - region: Optional: The state, province, or region of the cardholder's billing address.
    ///   - postalCode: Optional: The postal or ZIP code of the cardholder's billing address.
    ///   - countryCodeAlpha2: Optional: The 2-letter ISO 3166-1 country code of the cardholder's billing address.
    public init(
        cardNumber: String,
        expirationMonth: String,
        expirationYear: String,
        cvv: String? = nil,
        cardholderName: String? = nil,
        streetAddress: String? = nil,
        extendedAddress: String? = nil,
        locality: String? = nil,
        region: String? = nil,
        postalCode: String? = nil,
        countryCodeAlpha2: String? = nil
    ) {
        self.cardNumber = cardNumber
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cvv = cvv
        self.cardholderName = cardholderName
        self.streetAddress = streetAddress
        self.extendedAddress = extendedAddress
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.countryCodeAlpha2 = countryCodeAlpha2
        super.init()
    }
    
    // MARK: - BTPaymentActionRequest
    
    override func paymentMethodParameters() throws -> any Encodable {
        CardPaymentMethodPayload(card: self)
    }
}
