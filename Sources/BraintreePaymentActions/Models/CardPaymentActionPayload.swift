import Foundation

/// The card payment method payload submitted to a Payment Action via `BTPaymentActionsClient`
struct CardPaymentMethodPayload: Encodable {
    
    let paymentMethodDetails: PaymentMethodDetails
    
    init(card: BTCreditCard) {
        self.paymentMethodDetails = PaymentMethodDetails(card: card)
    }
}

struct PaymentMethodDetails: Encodable {
    
    let creditCard: CreditCard
    
    init(card: BTCreditCard) {
        self.creditCard = CreditCard(card: card)
    }
}

struct CreditCard: Encodable {
    
    let number: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String?
    let cardholderName: String?
    let billingAddress: BillingAddress?
    
    init(card: BTCreditCard) {
        self.number = card.cardNumber
        self.expirationMonth = card.expirationMonth
        self.expirationYear = card.expirationYear
        self.cvv = card.cvv
        self.cardholderName = card.cardholderName
        self.billingAddress = BillingAddress(card: card)
    }
}

struct BillingAddress: Encodable {
    
    let streetAddress: String?
    let extendedAddress: String?
    let locality: String?
    let region: String?
    let postalCode: String?
    let countryCodeAlpha2: String?
    
    init?(card: BTCreditCard) {
        let billingAddressProperties = [
            card.streetAddress,
            card.extendedAddress,
            card.locality,
            card.region,
            card.postalCode,
            card.countryCodeAlpha2
        ]
        
        if billingAddressProperties.allSatisfy({ $0?.isEmpty ?? true }) {
            return nil
        }
        
        self.streetAddress = card.streetAddress
        self.extendedAddress = card.extendedAddress
        self.locality = card.locality
        self.region = card.region
        self.postalCode = card.postalCode
        self.countryCodeAlpha2 = card.countryCodeAlpha2
    }
}
