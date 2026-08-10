import Foundation

/// The card details to submit as the payment method for a Payment Action.
@objcMembers public class BTCardPaymentActionRequest: NSObject, BTPaymentActionRequest {

    // MARK: - Public Properties

    /// The ID of the Payment Action to submit this payment method for.
    public let paymentActionID: String

    /// The card number.
    public let cardNumber: String

    /// The 2-digit expiration month i.e. "08"
    public let expirationMonth: String

    /// The 2 or 4-digit expiration year.
    public let expirationYear: String

    /// The card verification value. Optional depending on merchant configuration.
    public let cvv: String?

    /// The cardholder's name as it appears on the card.
    public let cardholderName: String?

    /// The street address line of the cardholder's billing address.
    public let streetAddress: String?

    /// The extended address line (e.g. apartment, suite, or unit number) of the cardholder's billing address.
    public let extendedAddress: String?

    /// The city or locality of the cardholder's billing address.
    public let locality: String?

    /// The state, province, or region of the cardholder's billing address.
    public let region: String?

    /// The postal or ZIP code of the cardholder's billing address.
    public let postalCode: String?

    /// The 2-letter ISO 3166-1 country code of the cardholder's billing address.
    public let countryCodeAlpha2: String?

    // MARK: - Initializer

    public init(
        paymentActionID: String,
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
        self.paymentActionID = paymentActionID
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
    }
}

// MARK: - BTPaymentActionRequest

extension BTCardPaymentActionRequest {

    public func paymentMethodParameters() -> any Encodable {
        PaymentMethodPayload(card: .init(request: self))
    }

    struct PaymentMethodPayload: Encodable {

        let card: Card
    }

    struct Card: Encodable {

        let number: String
        let expirationMonth: String
        let expirationYear: String
        let cvv: String?
        let cardholderName: String?
        let billingAddress: BillingAddress?

        init(request: BTCardPaymentActionRequest) {
            self.number = request.cardNumber
            self.expirationMonth = request.expirationMonth
            self.expirationYear = request.expirationYear
            self.cvv = request.cvv
            self.cardholderName = request.cardholderName
            self.billingAddress = BillingAddress(request: request)
        }
    }

    struct BillingAddress: Encodable {

        let streetAddress: String?
        let extendedAddress: String?
        let locality: String?
        let region: String?
        let postalCode: String?
        let countryCodeAlpha2: String?

        init?(request: BTCardPaymentActionRequest) {
            let billingAddressProperties = [
                request.streetAddress,
                request.extendedAddress,
                request.locality,
                request.region,
                request.postalCode,
                request.countryCodeAlpha2
            ]

            // if no billing address fields exist, we want to omit the billing address entirely
            if billingAddressProperties.allSatisfy({ $0?.isEmpty ?? true }) {
                return nil
            }

            self.streetAddress = request.streetAddress
            self.extendedAddress = request.extendedAddress
            self.locality = request.locality
            self.region = request.region
            self.postalCode = request.postalCode
            self.countryCodeAlpha2 = request.countryCodeAlpha2
        }
    }
}
